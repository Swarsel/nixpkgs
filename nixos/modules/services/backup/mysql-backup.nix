{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mysqlBackup;
  defaultUser = "mysqlbackup";

  # Newer mariadb versions warn of the usage of 'mysqldump' and recommend 'mariadb-dump' (https://mariadb.com/kb/en/mysqldump/)
  dumpBinary =
    if
      (
        lib.getName config.services.mysql.package == lib.getName pkgs.mariadb
        && lib.versionAtLeast config.services.mysql.package.version "11.0.0"
      )
    then
      "${config.services.mysql.package}/bin/mariadb-dump"
    else
      "${config.services.mysql.package}/bin/mysqldump";

  compressionAlgs = {
    gzip = rec {
      cmd = compressionLevelFlag: "${pkg}/bin/gzip -c ${cfg.gzipOptions} ${compressionLevelFlag}";
      ext = ".gz";
      maxLevel = 9;
      minLevel = 1;
      pkg = pkgs.gzip;
    };

    xz = rec {
      cmd = compressionLevelFlag: "${pkg}/bin/xz -z -c ${compressionLevelFlag} -";
      ext = ".xz";
      maxLevel = 9;
      minLevel = 0;
      pkg = pkgs.xz;
    };

    zstd = rec {
      cmd = compressionLevelFlag: "${pkg}/bin/zstd ${compressionLevelFlag} -";
      ext = ".zst";
      maxLevel = 19;
      minLevel = 1;
      pkg = pkgs.zstd;
    };
  };

  compressionLevelFlag = lib.optionalString (cfg.compressionLevel != null) (
    "-" + toString cfg.compressionLevel
  );

  selectedAlg = compressionAlgs.${cfg.compressionAlg};
  compressionCmd = selectedAlg.cmd compressionLevelFlag;

  shouldUseSingleTransaction =
    db:
    if lib.isBool cfg.singleTransaction then
      cfg.singleTransaction
    else
      lib.elem db cfg.singleTransaction;

  backupScript = ''
    set -o pipefail
    failed=""
    ${lib.concatMapStringsSep "\n" backupDatabaseScript cfg.databases}
    if [ -n "$failed" ]; then
      echo "Backup of database(s) failed:$failed"
      exit 1
    fi
  '';

  backupDatabaseScript = db: ''
    dest="${cfg.location}/${db}${selectedAlg.ext}"
    if ${dumpBinary} ${lib.optionalString (shouldUseSingleTransaction db) "--single-transaction"} ${db} | ${compressionCmd} > $dest.tmp; then
      mv $dest.tmp $dest
      echo "Backed up to $dest"
    else
      echo "Failed to back up to $dest"
      rm -f $dest.tmp
      failed="$failed ${db}"
    fi
  '';

in
{
  options = {
    services.mysqlBackup = {
      enable = lib.mkEnableOption "MySQL backups";

      calendar = lib.mkOption {
        default = "01:15:00";

        description = ''
          Configured when to run the backup service systemd unit (DayOfWeek Year-Month-Day Hour:Minute:Second).
        '';

        type = lib.types.str;
      };

      compressionAlg = lib.mkOption {
        default = "gzip";

        description = ''
          Compression algorithm to use for database dumps.
        '';

        type = lib.types.enum (lib.attrNames compressionAlgs);
      };

      compressionLevel = lib.mkOption {
        default = null;

        description = ''
          Compression level to use for ${lib.concatStringsSep ", " (lib.init (lib.attrNames compressionAlgs))} or ${lib.last (lib.attrNames compressionAlgs)}.
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: algo: "- For ${name}: ${toString algo.minLevel}-${toString algo.maxLevel}"
            ) compressionAlgs
          )}

          :::{.note}
          If compression level is also specified in gzipOptions, the gzipOptions value will be overwritten
          :::
        '';

        type = lib.types.nullOr lib.types.int;
      };

      databases = lib.mkOption {
        default = [ ];

        description = ''
          List of database names to dump.
        '';

        type = lib.types.listOf lib.types.str;
      };

      gzipOptions = lib.mkOption {
        default = "--no-name --rsyncable";

        description = ''
          Command line options to use when invoking `gzip`.
          Only used when compression is set to "gzip".
          If compression level is specified both here and in compressionLevel, the compressionLevel value will take precedence.
        '';

        type = lib.types.str;
      };

      location = lib.mkOption {
        default = "/var/backup/mysql";

        description = ''
          Location to put the compressed MySQL database dumps.
        '';

        type = lib.types.path;
      };

      singleTransaction = lib.mkOption {
        default = false;

        description = ''
          Whether to create database dump in a single transaction.
          Can be either a boolean for all databases or a list of database names.
        '';

        type = lib.types.oneOf [
          lib.types.bool
          (lib.types.listOf lib.types.str)
        ];
      };

      user = lib.mkOption {
        default = defaultUser;

        description = ''
          User to be used to perform backup.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # assert config to be correct
    assertions = [
      {
        assertion =
          cfg.compressionLevel == null
          || selectedAlg.minLevel <= cfg.compressionLevel && cfg.compressionLevel <= selectedAlg.maxLevel;

        message = "${cfg.compressionAlg} compression level must be between ${toString selectedAlg.minLevel} and ${toString selectedAlg.maxLevel}";
      }
      {
        assertion =
          !(lib.isList cfg.singleTransaction)
          || lib.all (db: lib.elem db cfg.databases) cfg.singleTransaction;

        message = "All databases in singleTransaction must be included in the databases option";
      }
    ];

    # add the compression tool to the system environment.
    environment.systemPackages = [ selectedAlg.pkg ];

    # ensure database user to be used to perform backup exist.
    services.mysql.ensureUsers = [
      {
        ensurePermissions =
          let
            privs = "SELECT, SHOW VIEW, TRIGGER, LOCK TABLES";
            grant = db: lib.nameValuePair "\\`${db}\\`.*" privs;
          in
          lib.listToAttrs (map grant cfg.databases);

        name = cfg.user;
      }
    ];

    systemd = {
      services.mysql-backup = {
        enable = true;
        description = "MySQL backup service";
        script = backupScript;

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
        };
      };

      timers.mysql-backup = {
        description = "Mysql backup timer";

        timerConfig = {
          AccuracySec = "5m";
          OnCalendar = cfg.calendar;
          Unit = "mysql-backup.service";
        };

        wantedBy = [ "timers.target" ];
      };

      tmpfiles.rules = [
        "d ${cfg.location} 0700 ${cfg.user} - - -"
      ];
    };

    # ensure unix user to be used to perform backup exist.
    users.users = lib.optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        createHome = false;
        group = "nogroup";
        home = cfg.location;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = [ lib.maintainers._6543 ];
}

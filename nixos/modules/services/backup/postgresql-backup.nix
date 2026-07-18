{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.postgresqlBackup;

  postgresqlBackupService =
    db: dumpCmd:
    let
      compressSuffixes = {
        "gzip" = ".gz";
        "none" = "";
        "zstd" = ".zstd";
      };
      compressSuffix = lib.getAttr cfg.compression compressSuffixes;

      compressCmd = lib.getAttr cfg.compression {
        "gzip" = "${pkgs.gzip}/bin/gzip -c -${toString cfg.compressionLevel} --rsyncable";
        "none" = "cat";
        "zstd" = "${pkgs.zstd}/bin/zstd -c -${toString cfg.compressionLevel} --rsyncable";
      };

      mkSqlPath = prefix: suffix: "${cfg.location}/${db}${prefix}.sql${suffix}";
      curFile = mkSqlPath "" compressSuffix;
      prevFile = mkSqlPath ".prev" compressSuffix;
      prevFiles = map (mkSqlPath ".prev") (lib.attrValues compressSuffixes);
      inProgressFile = mkSqlPath ".in-progress" compressSuffix;
    in
    {
      enable = true;
      description = "Backup of ${db} database(s)";

      path = [
        pkgs.coreutils
        config.services.postgresql.package
      ];

      requires = [ "postgresql.target" ];

      script = ''
        set -e -o pipefail

        umask 0077 # ensure backup is only readable by postgres user

        if [ -e ${curFile} ]; then
          rm -f ${toString prevFiles}
          mv ${curFile} ${prevFile}
        fi

        ${dumpCmd} \
          | ${compressCmd} \
          > ${inProgressFile}

        mv ${inProgressFile} ${curFile}
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
      };

      startAt = cfg.startAt;
    };

in
{

  imports = [
    (lib.mkRemovedOptionModule [ "services" "postgresqlBackup" "period" ] ''
      A systemd timer is now used instead of cron.
      The starting time can be configured via <literal>services.postgresqlBackup.startAt</literal>.
    '')
  ];

  options = {
    services.postgresqlBackup = {
      enable = lib.mkEnableOption "PostgreSQL dumps";

      backupAll = lib.mkOption {
        default = cfg.databases == [ ];
        defaultText = lib.literalExpression "services.postgresqlBackup.databases == []";

        description = ''
          Backup all databases using pg_dumpall.
          This option is mutual exclusive to
          `services.postgresqlBackup.databases`.
          The resulting backup dump will have the name all.sql.gz.
          This option is the default if no databases are specified.
        '';

        type = lib.types.bool;
      };

      compression = lib.mkOption {
        default = "gzip";

        description = ''
          The type of compression to use on the generated database dump.
        '';

        type = lib.types.enum [
          "none"
          "gzip"
          "zstd"
        ];
      };

      compressionLevel = lib.mkOption {
        default = 6;

        description = ''
          The compression level used when compression is enabled.
          gzip accepts levels 1 to 9. zstd accepts levels 1 to 19.
        '';

        type = lib.types.ints.between 1 19;
      };

      databases = lib.mkOption {
        default = [ ];

        description = ''
          List of database names to dump.
        '';

        type = lib.types.listOf lib.types.str;
      };

      location = lib.mkOption {
        default = "/var/backup/postgresql";

        description = ''
          Path of directory where the PostgreSQL database dumps will be placed.
        '';

        type = lib.types.path;
      };

      pgdumpAllOptions = lib.mkOption {
        default = "";

        description = ''
          Command line options for pg_dumpall. This options is not used if
          `config.services.postgresqlBackup.backupAll` is disabled.
        '';

        type = lib.types.separatedString " ";
      };

      pgdumpOptions = lib.mkOption {
        default = "-C";

        description = ''
          Command line options for pg_dump. This options is not used if
          `config.services.postgresqlBackup.backupAll` is enabled. Note that
          config.services.postgresqlBackup.backupAll is also active, when no
          databases where specified.
        '';

        type = lib.types.separatedString " ";
      };

      startAt = lib.mkOption {
        default = "*-*-* 01:15:00";

        description = ''
          This option defines (see `systemd.time` for format) when the
          databases should be dumped.
          The default is to update at 01:15 (at night) every day.
        '';

        type = with lib.types; either (listOf str) str;
      };
    };

  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.backupAll -> cfg.databases == [ ];
            message = "config.services.postgresqlBackup.backupAll cannot be used together with config.services.postgresqlBackup.databases";
          }
          {
            assertion =
              cfg.compression == "none"
              || (cfg.compression == "gzip" && cfg.compressionLevel >= 1 && cfg.compressionLevel <= 9)
              || (cfg.compression == "zstd" && cfg.compressionLevel >= 1 && cfg.compressionLevel <= 19);

            message = "config.services.postgresqlBackup.compressionLevel must be set between 1 and 9 for gzip and 1 and 19 for zstd";
          }
        ];

        systemd.tmpfiles.rules = [
          "d '${cfg.location}' 0700 postgres - - -"
        ];
      }

      (lib.mkIf cfg.backupAll {
        systemd.services.postgresqlBackup = postgresqlBackupService "all" "pg_dumpall ${cfg.pgdumpAllOptions}";
      })

      (lib.mkIf (!cfg.backupAll) {
        systemd.services = lib.listToAttrs (
          map (
            db:
            let
              cmd = "pg_dump ${cfg.pgdumpOptions} ${db}";
            in
            {
              name = "postgresqlBackup-${db}";
              value = postgresqlBackupService db cmd;
            }
          ) cfg.databases
        );
      })
    ]
  );

  meta.maintainers = with lib.maintainers; [ Scrumplex ];
}

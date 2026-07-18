{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.beesd;

  logLevels = {
    alert = 1;
    crit = 2;
    debug = 7;
    emerg = 0;
    err = 3;
    info = 6;
    notice = 5;
    warning = 4;
  };

  fsOptions = with lib.types; {
    options.extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Extra command-line options passed to the daemon. See upstream bees documentation.
      '';

      example = lib.literalExpression ''
        [ "--thread-count" "4" ]
      '';

      type = listOf str;
    };

    options.hashTableSizeMB = lib.mkOption {
      default = 1024; # 1GB; default from upstream beesd script

      description = ''
        Hash table size in MB; must be a multiple of 16.

        A larger ratio of index size to storage size means smaller blocks of
        duplicate content are recognized.

        If you have 1TB of data, a 4GB hash table (which is to say, a value of
        4096) will permit 4KB extents (the smallest possible size) to be
        recognized, whereas a value of 1024 -- creating a 1GB hash table --
        will recognize only aligned duplicate blocks of 16KB.
      '';

      type = lib.types.addCheck lib.types.int (n: lib.mod n 16 == 0);
    };

    options.spec = lib.mkOption {
      description = ''
        Description of how to identify the filesystem to be duplicated by this
        instance of bees. Note that deduplication crosses subvolumes; one must
        not configure multiple instances for subvolumes of the same filesystem
        (or block devices which are part of the same filesystem), but only for
        completely independent btrfs filesystems.

        This must be in a format usable by findmnt; that could be a key=value
        pair, or a bare path to a mount point.
        Using bare paths will allow systemd to start the beesd service only
        after mounting the associated path.
      '';

      example = "LABEL=MyBulkDataDrive";
      type = str;
    };

    options.verbosity = lib.mkOption {
      apply = v: if lib.isString v then logLevels.${v} else v;
      default = "info";
      description = "Log verbosity (syslog keyword/level).";
      type = lib.types.enum (lib.attrNames logLevels ++ lib.attrValues logLevels);
    };

    options.workDir = lib.mkOption {
      default = ".beeshome";

      description = ''
        Name (relative to the root of the filesystem) of the subvolume where
        the hash table will be stored.
      '';

      type = str;
    };
  };

in
{

  options.services.beesd = {
    filesystems = lib.mkOption {
      default = { };
      description = "BTRFS filesystems to run block-level deduplication on.";

      example = lib.literalExpression ''
        {
          "-" = {
            spec = "LABEL=root";
            hashTableSizeMB = 2048;
            verbosity = "crit";
            extraOptions = [ "--loadavg-target" "5.0" ];
          };
        }
      '';

      type = with lib.types; attrsOf (submodule fsOptions);
    };
  };

  config = lib.mkIf (cfg.filesystems != { }) {
    systemd.packages = [ pkgs.bees ];

    systemd.services = lib.mapAttrs' (
      name: fs:
      lib.nameValuePair "beesd@${name}" {
        overrideStrategy = "asDropin";

        serviceConfig = {
          ExecStart =
            let
              configOpts = [
                fs.spec
                "verbosity=${toString fs.verbosity}"
                "idxSizeMB=${toString fs.hashTableSizeMB}"
                "workDir=${fs.workDir}"
              ];
              configOptsStr = lib.escapeShellArgs configOpts;
            in
            [
              ""
              "${pkgs.bees}/bin/bees-service-wrapper run ${configOptsStr} -- --no-timestamps ${lib.escapeShellArgs fs.extraOptions}"
            ];

          # Ensure that hashtable can be locked into memory
          LimitMEMLOCK = "${toString fs.hashTableSizeMB}M";
          MemoryMin = "${toString fs.hashTableSizeMB}M";
          SyslogIdentifier = "beesd"; # would otherwise be "bees-service-wrapper"
        };

        unitConfig.RequiresMountsFor = lib.mkIf (lib.hasPrefix "/" fs.spec) fs.spec;
        wantedBy = [ "multi-user.target" ];
      }
    ) cfg.filesystems;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.snapraid;
in
{
  imports = [
    # Should have never been on the top-level.
    (lib.mkRenamedOptionModule [ "snapraid" ] [ "services" "snapraid" ])
  ];

  options.services.snapraid = with lib.types; {
    enable = lib.mkEnableOption "SnapRAID";

    contentFiles = lib.mkOption {
      default = [ ];
      description = "SnapRAID content list files.";

      example = [
        "/var/snapraid.content"
        "/mnt/disk1/snapraid.content"
        "/mnt/disk2/snapraid.content"
      ];

      type = listOf str;
    };

    dataDisks = lib.mkOption {
      default = { };
      description = "SnapRAID data disks.";

      example = {
        d1 = "/mnt/disk1/";
        d2 = "/mnt/disk2/";
        d3 = "/mnt/disk3/";
      };

      type = attrsOf str;
    };

    exclude = lib.mkOption {
      default = [ ];
      description = "SnapRAID exclude directives.";

      example = [
        "*.unrecoverable"
        "/tmp/"
        "/lost+found/"
      ];

      type = listOf str;
    };

    extraConfig = lib.mkOption {
      default = "";
      description = "Extra config options for SnapRAID.";

      example = ''
        nohidden
        blocksize 256
        hashsize 16
        autosave 500
        pool /pool
      '';

      type = lines;
    };

    parityFiles = lib.mkOption {
      default = [ ];
      description = "SnapRAID parity files.";

      example = [
        "/mnt/diskp/snapraid.parity"
        "/mnt/diskq/snapraid.2-parity"
        "/mnt/diskr/snapraid.3-parity"
        "/mnt/disks/snapraid.4-parity"
        "/mnt/diskt/snapraid.5-parity"
        "/mnt/disku/snapraid.6-parity"
      ];

      type = listOf str;
    };

    scrub = {
      interval = lib.mkOption {
        default = "Mon *-*-* 02:00:00";
        description = "How often to run {command}`snapraid scrub`.";
        example = "weekly";
        type = str;
      };

      olderThan = lib.mkOption {
        default = 10;
        description = "Number of days since data was last scrubbed before it can be scrubbed again.";
        example = 20;
        type = int;
      };

      plan = lib.mkOption {
        default = 8;
        description = "Percent of the array that should be checked by {command}`snapraid scrub`.";
        example = 5;
        type = int;
      };
    };

    sync.interval = lib.mkOption {
      default = "01:00";
      description = "How often to run {command}`snapraid sync`.";
      example = "daily";
      type = str;
    };

    touchBeforeSync = lib.mkOption {
      default = true;
      description = "Whether {command}`snapraid touch` should be run before {command}`snapraid sync`.";
      example = false;
      type = bool;
    };
  };

  config =
    let
      nParity = builtins.length cfg.parityFiles;
      mkPrepend = pre: s: pre + s;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = nParity <= 6;
          message = "You can have no more than six SnapRAID parity files.";
        }
        {
          assertion = builtins.length cfg.contentFiles >= nParity + 1;
          message = "There must be at least one SnapRAID content file for each SnapRAID parity file plus one.";
        }
      ];

      environment = {
        etc."snapraid.conf" = {
          text =
            with cfg;
            let
              prependData = mkPrepend "data ";
              prependContent = mkPrepend "content ";
              prependExclude = mkPrepend "exclude ";
            in
            lib.concatStringsSep "\n" (
              map prependData ((lib.mapAttrsToList (name: value: name + " " + value)) dataDisks)
              ++ lib.zipListsWith (a: b: a + b) (
                [ "parity " ] ++ map (i: toString i + "-parity ") (lib.range 2 6)
              ) parityFiles
              ++ map prependContent contentFiles
              ++ map prependExclude exclude
            )
            + "\n"
            + extraConfig;
        };

        systemPackages = with pkgs; [ snapraid ];
      };

      systemd.services = with cfg; {
        snapraid-scrub = {
          description = "Scrub the SnapRAID array";

          serviceConfig = {
            CPUSchedulingPolicy = "batch";
            CapabilityBoundingSet = "CAP_DAC_OVERRIDE";
            ExecStart = "${pkgs.snapraid}/bin/snapraid scrub -p ${toString scrub.plan} -o ${toString scrub.olderThan}";
            IOSchedulingPriority = 7;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            Nice = 19;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = "read-only";
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "strict";

            ReadWritePaths =
              # scrub requires access to directories containing content files
              # to remove them if they are stale
              let
                contentDirs = map dirOf contentFiles;
              in
              lib.unique (lib.attrValues dataDisks ++ contentDirs);

            RestrictAddressFamilies = "none";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = "@system-service";
            Type = "oneshot";
          };

          startAt = scrub.interval;
          unitConfig.After = "snapraid-sync.service";
        };

        snapraid-sync = {
          description = "Synchronize the state of the SnapRAID array";

          serviceConfig = {
            CPUSchedulingPolicy = "batch";
            CapabilityBoundingSet = "CAP_DAC_OVERRIDE" + lib.optionalString cfg.touchBeforeSync " CAP_FOWNER";
            ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
            IOSchedulingPriority = 7;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            Nice = 19;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = "read-only";
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "strict";

            ReadWritePaths =
              # sync requires access to directories containing content files
              # to remove them if they are stale
              let
                contentDirs = map dirOf contentFiles;
                # Multiple "split" parity files can be specified in a single
                # "parityFile", separated by a comma.
                # https://www.snapraid.it/manual#7.1
                splitParityFiles = map (s: lib.splitString "," s) parityFiles;
              in
              lib.unique (lib.attrValues dataDisks ++ splitParityFiles ++ contentDirs);

            RestrictAddressFamilies = "none";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = "@system-service";
            Type = "oneshot";
          }
          // lib.optionalAttrs touchBeforeSync {
            ExecStartPre = "${pkgs.snapraid}/bin/snapraid touch";
          };

          startAt = sync.interval;
        };
      };
    };
}

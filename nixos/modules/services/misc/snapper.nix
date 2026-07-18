{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.snapper;

  mkValue =
    v:
    if lib.isList v then
      "\"${
        lib.concatMapStringsSep " " (lib.escape [
          "\\"
          " "
        ]) v
      }\""
    else if v == true then
      "yes"
    else if v == false then
      "no"
    else if lib.isString v then
      "\"${v}\""
    else
      builtins.toJSON v;

  mkKeyValue = k: v: "${k}=${mkValue v}";

  # "it's recommended to always specify the filesystem type"  -- man snapper-configs
  defaultOf = k: if k == "FSTYPE" then null else configOptions.${k}.default or null;

  safeStr = lib.types.strMatching "[^\n\"]*" // {
    description = "string without line breaks or quotes";
    descriptionClass = "conjunction";
  };

  intOrNumberOrRange = lib.types.either lib.types.ints.unsigned (
    lib.types.strMatching "[[:digit:]]+(-[[:digit:]]+)?"
    // {
      description = "string containing either a number or a range";
      descriptionClass = "conjunction";
    }
  );

  configOptions = {
    ALLOW_GROUPS = lib.mkOption {
      default = [ ];

      description = ''
        List of groups allowed to operate with the config.

        Also see the PERMISSIONS section in man:snapper(8).
      '';

      type = lib.types.listOf safeStr;
    };

    ALLOW_USERS = lib.mkOption {
      default = [ ];

      description = ''
        List of users allowed to operate with the config. "root" is always
        implicitly included.

        Also see the PERMISSIONS section in man:snapper(8).
      '';

      example = [ "alice" ];
      type = lib.types.listOf safeStr;
    };

    FSTYPE = lib.mkOption {
      default = "btrfs";

      description = ''
        Filesystem type. Only btrfs is stable and tested.

        bcachefs support is experimental.
      '';

      type = lib.types.enum [
        "btrfs"
        "bcachefs"
      ];
    };

    SUBVOLUME = lib.mkOption {
      description = ''
        Path of the subvolume or mount point.
        This path is a subvolume and has to contain a subvolume named
        .snapshots.
        See also man:snapper(8) section PERMISSIONS.
      '';

      type = lib.types.path;
    };

    TIMELINE_CLEANUP = lib.mkOption {
      default = false;

      description = ''
        Defines whether the timeline cleanup algorithm should be run for the config.
      '';

      type = lib.types.bool;
    };

    TIMELINE_CREATE = lib.mkOption {
      default = false;

      description = ''
        Defines whether hourly snapshots should be created.
      '';

      type = lib.types.bool;
    };

    TIMELINE_LIMIT_DAILY = lib.mkOption {
      default = 10;

      description = ''
        Limits for timeline cleanup.
      '';

      type = intOrNumberOrRange;
    };

    TIMELINE_LIMIT_HOURLY = lib.mkOption {
      default = 10;

      description = ''
        Limits for timeline cleanup.
      '';

      type = intOrNumberOrRange;
    };

    TIMELINE_LIMIT_MONTHLY = lib.mkOption {
      default = 10;

      description = ''
        Limits for timeline cleanup.
      '';

      type = intOrNumberOrRange;
    };

    TIMELINE_LIMIT_QUARTERLY = lib.mkOption {
      default = 0;

      description = ''
        Limits for timeline cleanup.
      '';

      type = intOrNumberOrRange;
    };

    TIMELINE_LIMIT_WEEKLY = lib.mkOption {
      default = 0;

      description = ''
        Limits for timeline cleanup.
      '';

      type = intOrNumberOrRange;
    };

    TIMELINE_LIMIT_YEARLY = lib.mkOption {
      default = 10;

      description = ''
        Limits for timeline cleanup.
      '';

      type = intOrNumberOrRange;
    };
  };
in

{
  options.services.snapper = {

    cleanupInterval = lib.mkOption {
      default = "1d";

      description = ''
        Cleanup interval.

        The format is described in
        {manpage}`systemd.time(7)`.
      '';

      type = lib.types.str;
    };

    configs = lib.mkOption {
      default = { };

      description = ''
        Subvolume configuration. Any option mentioned in man:snapper-configs(5)
        is valid here, even if NixOS doesn't document it.
      '';

      example = lib.literalExpression ''
        {
          home = {
            SUBVOLUME = "/home";
            ALLOW_USERS = [ "alice" ];
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
          };
        }
      '';

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = configOptions;

          freeformType = lib.types.attrsOf (
            lib.types.oneOf [
              (lib.types.listOf safeStr)
              lib.types.bool
              safeStr
              lib.types.number
            ]
          );
        }
      );
    };

    filters = lib.mkOption {
      default = null;

      description = ''
        Global display difference filter. See man:snapper(8) for more details.
      '';

      type = lib.types.nullOr lib.types.lines;
    };

    persistentTimer = lib.mkOption {
      default = false;

      description = ''
        Set the `Persistent` option for the
        {manpage}`systemd.timer(5)`
        which triggers the snapshot immediately if the last trigger
        was missed (e.g. if the system was powered down).
      '';

      example = true;
      type = lib.types.bool;
    };

    snapshotInterval = lib.mkOption {
      default = "hourly";

      description = ''
        Snapshot interval.

        The format is described in
        {manpage}`systemd.time(7)`.
      '';

      type = lib.types.str;
    };

    snapshotRootOnBoot = lib.mkOption {
      default = false;

      description = ''
        Whether to snapshot root on boot
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf (cfg.configs != { }) (
    let
      documentation = [
        "man:snapper(8)"
        "man:snapper-configs(5)"
      ];
    in
    {
      assertions = lib.concatMap (
        name:
        let
          sub = cfg.configs.${name};
        in
        [
          {
            assertion = !(sub ? extraConfig);

            message = ''
              The option definition `services.snapper.configs.${name}.extraConfig' no longer has any effect; please remove it.
              The contents of this option should be migrated to attributes on `services.snapper.configs.${name}'.
            '';
          }
        ]
        ++
          map
            (attr: {
              assertion = !(lib.hasAttr attr sub);

              message = ''
                The option definition `services.snapper.configs.${name}.${attr}' has been renamed to `services.snapper.configs.${name}.${lib.toUpper attr}'.
              '';
            })
            [
              "fstype"
              "subvolume"
            ]
      ) (lib.attrNames cfg.configs);

      environment = {

        # Note: snapper/config-templates/default is only needed for create-config
        #       which is not the NixOS way to configure.
        etc = {

          "sysconfig/snapper".text = ''
            SNAPPER_CONFIGS="${lib.concatStringsSep " " (builtins.attrNames cfg.configs)}"
          '';
        }
        // (lib.mapAttrs' (
          name: subvolume:
          lib.nameValuePair "snapper/configs/${name}" {
            text = lib.generators.toKeyValue { inherit mkKeyValue; } (
              lib.filterAttrs (k: v: v != defaultOf k) subvolume
            );
          }
        ) cfg.configs)
        // (lib.optionalAttrs (cfg.filters != null) { "snapper/filters/default.txt".text = cfg.filters; });

        systemPackages = [ pkgs.snapper ];
      };

      services.dbus.packages = [ pkgs.snapper ];

      systemd.services.snapper-boot = lib.mkIf cfg.snapshotRootOnBoot {
        inherit documentation;
        description = "Take snapper snapshot of root on boot";
        requires = [ "local-fs.target" ];
        serviceConfig.ExecStart = "${pkgs.snapper}/bin/snapper --config root create --cleanup-algorithm number --description boot";
        serviceConfig.Type = "oneshot";
        unitConfig.ConditionPathExists = "/etc/snapper/configs/root";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.snapper-cleanup = {
        inherit documentation;
        description = "Cleanup of Snapper Snapshots";
        serviceConfig.ExecStart = "${pkgs.snapper}/lib/snapper/systemd-helper --cleanup";
      };

      systemd.services.snapper-timeline = {
        inherit documentation;
        description = "Timeline of Snapper Snapshots";
        requires = [ "local-fs.target" ];
        serviceConfig.ExecStart = "${pkgs.snapper}/lib/snapper/systemd-helper --timeline";
      };

      systemd.services.snapperd = {
        inherit documentation;
        description = "DBus interface for snapper";

        serviceConfig = {
          BusName = "org.opensuse.Snapper";
          CapabilityBoundingSet = "CAP_DAC_OVERRIDE CAP_FOWNER CAP_CHOWN CAP_FSETID CAP_SETFCAP CAP_SYS_ADMIN CAP_SYS_MODULE CAP_IPC_LOCK CAP_SYS_NICE";
          ExecStart = "${pkgs.snapper}/bin/snapperd";
          LockPersonality = true;
          NoNewPrivileges = false;
          PrivateNetwork = true;
          ProtectHostname = true;
          RestrictAddressFamilies = "AF_UNIX";
          RestrictRealtime = true;
          Type = "dbus";
        };
      };

      systemd.timers.snapper-cleanup = {
        inherit documentation;
        description = "Cleanup of Snapper Snapshots";
        requires = [ "local-fs.target" ];
        timerConfig.OnBootSec = "10m";
        timerConfig.OnUnitActiveSec = cfg.cleanupInterval;
        wantedBy = [ "timers.target" ];
      };

      systemd.timers.snapper-timeline = {
        timerConfig = {
          OnCalendar = cfg.snapshotInterval;
          Persistent = cfg.persistentTimer;
        };

        wantedBy = [ "timers.target" ];
      };
    }
  );

  meta.maintainers = with lib.maintainers; [ Djabx ];
}

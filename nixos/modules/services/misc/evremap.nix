{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.evremap;
  format = pkgs.formats.toml { };
  settings = lib.attrsets.filterAttrs (n: v: v != null) cfg.settings;
  configFile = format.generate "evremap.toml" settings;

  key = lib.types.strMatching "(BTN|KEY)_[[:upper:][:digit:]_]+" // {
    description = "key ID prefixed with BTN_ or KEY_";
  };

  mkKeyOption =
    description:
    lib.mkOption {
      description = ''
        ${description}

        You can get a list of keys by running `evremap list-keys`.
      '';

      type = key;
    };
  mkKeySeqOption =
    description:
    (mkKeyOption description)
    // {
      type = lib.types.listOf key;
    };

  dualRoleModule = lib.types.submodule {
    options = {
      hold = mkKeySeqOption "The key sequence that should be output when the input key is held.";
      input = mkKeyOption "The key that should be remapped.";
      tap = mkKeySeqOption "The key sequence that should be output when the input key is tapped.";
    };
  };

  remapModule = lib.types.submodule {
    options = {
      input = mkKeySeqOption "The key sequence that should be remapped.";
      output = mkKeySeqOption "The key sequence that should be output when the input sequence is entered.";
    };
  };
in
{
  options.services.evremap = {
    enable = lib.mkEnableOption "evremap, a keyboard input remapper for Linux/Wayland systems";

    settings = lib.mkOption {
      default = { };

      description = ''
        Settings for evremap.

        See the [upstream documentation](https://github.com/wez/evremap/blob/master/README.md#configuration)
        for how to configure evremap.
      '';

      type = lib.types.submodule {
        options = {
          device_name = lib.mkOption {
            description = ''
              The name of the device that should be remapped.

              You can get a list of devices by running `evremap list-devices` with elevated permissions.
            '';

            example = "AT Translated Set 2 keyboard";
            type = lib.types.str;
          };

          dual_role = lib.mkOption {
            default = [ ];

            description = ''
              List of dual-role remappings that output different key sequences based on whether the
              input key is held or tapped.
            '';

            example = [
              {
                hold = [ "KEY_LEFTCTRL" ];
                input = "KEY_CAPSLOCK";
                tap = [ "KEY_ESC" ];
              }
            ];

            type = lib.types.listOf dualRoleModule;
          };

          phys = lib.mkOption {
            default = null;

            description = ''
              The physical device name to listen on.

              This attribute may be specified to disambiguate multiple devices with the same device name.
              The physical device names of each device can be obtained by running `evremap list-devices` with elevated permissions.
            '';

            example = "usb-0000:07:00.3-2.1.1/input0";
            type = lib.types.nullOr lib.types.str;
          };

          remap = lib.mkOption {
            default = [ ];

            description = ''
              List of remappings.
            '';

            example = [
              {
                input = [
                  "KEY_LEFTALT"
                  "KEY_UP"
                ];

                output = [ "KEY_PAGEUP" ];
              }
            ];

            type = lib.types.listOf remapModule;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.evremap ];
    hardware.uinput.enable = true;

    systemd.services.evremap = {
      description = "evremap - keyboard input remapper";

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.evremap} remap ${configFile}";
        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        # Hardening
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "on-failure";
        RestartSec = 5;
        RestrictAddressFamilies = "none";
        RestrictNamespaces = true;
        RestrictRealtime = true;

        SupplementaryGroups = [
          config.users.groups.input.name
          config.users.groups.uinput.name
        ];

        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@resources"
          "~@privileged"
        ];

        TimeoutSec = 20;
        UMask = "0027";
        User = "evremap";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.flap-alerted;

  settingsArgs = lib.pipe cfg.settings [
    (lib.mapAttrsToList (
      name: value:
      if value == null || value == false then
        [ ]
      else if value == true then
        [ "-${name}" ]
      else
        [
          "-${name}"
          (toString value)
        ]
    ))
    lib.concatLists
  ];
in

{
  options.services.flap-alerted = {
    enable = lib.mkEnableOption "FlapAlerted";
    package = lib.mkPackageOption pkgs "flap-alerted" { };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files to load environment variables from.
        This is useful to avoid putting secrets into the nix store.
        See <https://github.com/Kioubit/FlapAlerted> for a list of options.
      '';

      example = [ "/run/secrets/flap-alerted.env" ];
      type = lib.types.listOf lib.types.path;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line arguments to pass to FlapAlerted.
        See <https://github.com/Kioubit/FlapAlerted> for a list of options.
      '';

      type = lib.types.listOf lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of FlapAlerted.
        See <https://github.com/Kioubit/FlapAlerted> for a list of options.
      '';

      type = lib.types.submodule {
        options = {
          asn = lib.mkOption {
            description = "Your ASN number";
            type = lib.types.ints.u32;
          };

          bgpListenAddress = lib.mkOption {
            default = ":1790";
            description = "Address to listen on for incoming BGP connections";
            type = lib.types.str;
          };

          debug = lib.mkOption {
            default = false;
            description = "Enable debug mode (produces a lot of output)";
            type = lib.types.bool;
          };
        };

        freeformType = lib.types.attrsOf (
          lib.types.nullOr (
            lib.types.oneOf [
              lib.types.str
              lib.types.int
              lib.types.bool
            ]
          )
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.flap-alerted = {
      after = [ "network-online.target" ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.escapeShellArgs ([ (lib.getExe cfg.package) ] ++ settingsArgs ++ cfg.extraArgs);
        Group = "flap-alerted";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "flap-alerted";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}

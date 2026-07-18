{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.flood;
in
{
  options.services.flood = {
    enable = lib.mkEnableOption "flood";
    package = lib.mkPackageOption pkgs "flood" { };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra arguments passed to `flood`.";
      example = [ "--baseuri=/" ];
      type = with lib.types; listOf str;
    };

    host = lib.mkOption {
      default = "localhost";
      description = "Host to bind webserver.";
      example = "::";
      type = lib.types.str;
    };

    openFirewall = lib.mkEnableOption "" // {
      description = "Whether to open the firewall for the port in {option}`services.flood.port`.";
    };

    port = lib.mkOption {
      default = 3000;
      description = "Port to bind webserver.";
      example = 3001;
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
    ];

    systemd.services.flood = {
      after = [ "network.target" ];
      description = "A modern web UI for various torrent clients.";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe cfg.package)
            "--host"
            cfg.host
            "--port"
            (toString cfg.port)
            "--rundir=/var/lib/flood"
          ]
          ++ cfg.extraArgs
        );

        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "3s";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "flood";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@pkey"
          "~@privileged"
        ];
      };

      unitConfig = {
        Documentation = "https://github.com/jesec/flood/wiki";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ thiagokokada ];
}

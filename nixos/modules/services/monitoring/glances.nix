{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.glances;

  inherit (lib)
    getExe
    maintainers
    mkEnableOption
    mkOption
    mkIf
    mkPackageOption
    ;

  inherit (lib.types)
    bool
    listOf
    port
    str
    ;

  inherit (utils)
    escapeSystemdExecArgs
    ;

in
{
  options.services.glances = {
    enable = mkEnableOption "Glances";
    package = mkPackageOption pkgs "glances" { };

    extraArgs = mkOption {
      default = [ "--webserver" ];

      description = ''
        Extra command-line arguments to pass to glances.

        See <https://glances.readthedocs.io/en/latest/cmds.html> for all available options.
      '';

      example = [
        "--webserver"
        "--disable-webui"
      ];

      type = listOf str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Open port in the firewall for glances.";
      type = bool;
    };

    port = mkOption {
      default = 61208;
      description = "Port the server will isten on.";
      type = port;
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services."glances" = {
      after = [ "network.target" ];
      description = "Glances";
      documentation = [ "man:glances(1)" ];

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        ExecStart = "${getExe cfg.package} --port ${toString cfg.port} ${escapeSystemdExecArgs cfg.extraArgs}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        ReadWritePaths = [ "/var/log" ];
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictRealtime = true;
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ claha ];
}

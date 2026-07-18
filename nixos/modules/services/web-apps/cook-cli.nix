{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cook-cli;
  inherit (lib)
    mkIf
    getExe
    ;
in
{
  options = {
    services.cook-cli = {
      enable = lib.mkEnableOption "cook-cli";
      package = lib.mkPackageOption pkgs "cook-cli" { };

      autoStart = lib.mkOption {
        default = true;

        description = ''
          Whether to start cook-cli server automatically.
        '';

        type = lib.types.bool;
      };

      basePath = lib.mkOption {
        default = "/var/lib/cook-cli";

        description = ''
          Path to the directory cook-cli will look for recipes.
        '';

        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the cook-cli server port in the firewall.
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 9080;

        description = ''
          Which port cook-cli server will use.
        '';

        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.cook-cli = {
      description = "cook-cli server";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_SYS_NICE" ];
        # Hardening options
        CapabilityBoundingSet = [ "CAP_SYS_NICE" ];
        ExecStart = "${getExe cfg.package} server --host --port ${toString cfg.port} ${cfg.basePath}";
        Group = "cook-cli";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = cfg.basePath;
        Restart = "on-failure";
        RestartSec = 5;
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        User = "cook-cli";
        WorkingDirectory = cfg.basePath;
      };

      wantedBy = mkIf cfg.autoStart [ "multi-user.target" ];
      wants = [ "network.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.basePath} 0770 cook-cli users"
    ];

    users.groups.cook-cli.members = [
      "cook-cli"
    ];

    users.users.cook-cli = {
      group = "cook-cli";
      home = "${cfg.basePath}";
      isSystemUser = true;
    };
  };

  meta.maintainers = [
    lib.maintainers.luNeder
    lib.maintainers.emilioziniades
  ];
}

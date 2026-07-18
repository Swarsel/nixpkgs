{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.porn-vault;
  configFormat = pkgs.formats.json { };
  defaultConfig = import ./default-config.nix;
  inherit (lib)
    mkIf
    mkOption
    getExe
    ;
in
{
  options = {
    services.porn-vault = {
      enable = lib.mkEnableOption "Porn-Vault";
      package = lib.mkPackageOption pkgs "porn-vault" { };

      autoStart = lib.mkOption {
        default = true;

        description = ''
          Whether to start porn-vault automatically.
        '';

        type = lib.types.bool;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the Porn-Vault port in the firewall.
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 3000;

        description = ''
          Which port Porn-Vault will use.
        '';

        type = lib.types.port;
      };

      settings = mkOption {
        apply = lib.recursiveUpdate defaultConfig;
        default = defaultConfig;

        description = ''
          Configuration for Porn-Vault. The attributes are serialized to JSON in config.json.

          See <https://gitlab.com/porn-vault/porn-vault/-/blob/dev/config.example.json>
        '';

        type = configFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "porn-vault/config.json".source = configFormat.generate "config.json" cfg.settings;
    };

    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.porn-vault = {
      description = "Porn-Vault server";

      environment = {
        DATABASE_NAME = "production";
        NODE_ENV = "production";
        PORT = toString cfg.port;
        PV_CONFIG_FOLDER = "/etc/porn-vault";
      };

      serviceConfig = {
        AmbientCapabilities = [ "CAP_SYS_NICE" ];
        CacheDirectory = "porn-vault";
        # Hardening options
        CapabilityBoundingSet = [ "CAP_SYS_NICE" ];
        ExecStart = getExe cfg.package;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        Restart = "on-failure";
        RestartSec = 5;
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
      };

      wantedBy = mkIf cfg.autoStart [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.luNeder ];
}

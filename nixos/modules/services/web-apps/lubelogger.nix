{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lubelogger;
in
{
  options = {
    services.lubelogger = {
      enable = lib.mkEnableOption "LubeLogger, a self-hosted, open-source, web-based vehicle maintenance and fuel milage tracker";
      package = lib.mkPackageOption pkgs "lubelogger" { };

      dataDir = lib.mkOption {
        default = "lubelogger";
        description = "Path to LubeLogger config and metadata inside of `/var/lib/`.";
        type = lib.types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Path to a file containing extra LubeLogger config options in the systemd `EnvironmentFile` format.
          Refer to the [documentation] for supported options.

          [documentation]: https://docs.lubelogger.com/Advanced/Environment%20Variables

          This can be used to pass secrets to LubeLogger without putting them in the Nix store.

          For example, to set an SMTP password, point `environmentFile` at a file containing:
          ```
          MailConfig__Password=<pass>
          ```
        '';

        example = "/run/secrets/lubelogger";
        type = lib.types.nullOr lib.types.path;
      };

      group = lib.mkOption {
        default = "lubelogger";
        description = "Group under which LubeLogger runs.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the LubeLogger web interface.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 5000;
        description = "The TCP port LubeLogger will listen on.";
        type = lib.types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Additional configuration for LubeLogger, see <https://docs.lubelogger.com/Environment%20Variables> for supported values.
        '';

        example = {
          LUBELOGGER_ALLOWED_FILE_EXTENSIONS = "";
          LUBELOGGER_LOGO_URL = "";
        };

        type = with lib.types; attrsOf str;
      };

      user = lib.mkOption {
        default = "lubelogger";
        description = "User account under which LubeLogger runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.lubelogger = {
      after = [ "network.target" ];
      description = "LubeLogger";

      environment = {
        Kestrel__Endpoints__Http__Url = "http://localhost:${toString cfg.port}";
      }
      // cfg.settings;

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        StateDirectory = cfg.dataDir;
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = "/var/lib/${cfg.dataDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "lubelogger") { lubelogger = { }; };

    users.users = lib.mkIf (cfg.user == "lubelogger") {
      lubelogger = {
        group = cfg.group;
        home = "/var/lib/${cfg.dataDir}";
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    bct
    lyndeno
  ];
}

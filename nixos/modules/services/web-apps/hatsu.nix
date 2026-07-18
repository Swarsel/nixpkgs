{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hatsu;
in
{
  options.services.hatsu = {
    enable = lib.mkEnableOption "Self-hosted and fully-automated ActivityPub bridge for static sites";
    package = lib.mkPackageOption pkgs "hatsu" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for Hatsu, see
        <https://hatsu.cli.rs/admins/environments.html>
        for supported values.
      '';

      type = lib.types.submodule {
        options = {
          HATSU_DATABASE_URL = lib.mkOption {
            default = "sqlite:///var/lib/hatsu/hatsu.sqlite?mode=rwc";
            description = "Database URL.";
            example = "postgres://username:password@host/database";
            type = lib.types.str;
          };

          HATSU_DOMAIN = lib.mkOption {
            description = "The domain name of your instance (eg 'hatsu.local').";
            type = lib.types.str;
          };

          HATSU_LISTEN_HOST = lib.mkOption {
            default = "127.0.0.1";
            description = "Host where hatsu should listen for incoming requests.";
            type = lib.types.str;
          };

          HATSU_LISTEN_PORT = lib.mkOption {
            apply = toString;
            default = 3939;
            description = "Port where hatsu should listen for incoming requests.";
            type = lib.types.port;
          };

          HATSU_PRIMARY_ACCOUNT = lib.mkOption {
            description = "The primary account of your instance (eg 'example.com').";
            type = lib.types.str;
          };
        };

        freeformType =
          with lib.types;
          attrsOf (
            nullOr (oneOf [
              bool
              int
              port
              str
            ])
          );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hatsu = {
      after = [ "network-online.target" ];
      description = "Hatsu server";
      documentation = [ "https://hatsu.cli.rs/" ];
      environment = cfg.settings;

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
        StateDirectory = "hatsu";
        Type = "simple";
        WorkingDirectory = "%S/hatsu";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.doc = ./hatsu.md;
  meta.maintainers = with lib.maintainers; [ kwaa ];
}

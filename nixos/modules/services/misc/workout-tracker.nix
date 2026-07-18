{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.workout-tracker;
  stateDir = "workout-tracker";
in

{
  options = {
    services.workout-tracker = {
      enable = lib.mkEnableOption "workout tracking web application for personal use (or family, friends), geared towards running and other GPX-based activities";
      package = lib.mkPackageOption pkgs "workout-tracker" { };

      address = lib.mkOption {
        default = "127.0.0.1";
        description = "Web interface address.";
        type = types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          An environment file as defined in {manpage}`systemd.exec(5)`.

          Secrets like `WT_JWT_ENCRYPTION_KEY` may be passed to the service without adding them
          to the world-readable Nix store.
        '';

        example = "/run/keys/workout-tracker.env";
        type = types.nullOr types.path;
      };

      port = lib.mkOption {
        default = 8080;
        description = "Web interface port.";
        type = types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Extra config options.
        '';

        example = {
          WT_DATABASE_DRIVER = "sqlite";
          WT_DEBUG = "false";
          WT_DSN = "./database.db";
          WT_LOGGING = "true";
        };

        type = types.attrsOf types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.workout-tracker = {
      description = "A workout tracking web application for personal use (or family, friends), geared towards running and other GPX-based activities";

      environment = {
        WT_BIND = "${cfg.address}:${toString cfg.port}";
        WT_DATABASE_DRIVER = "sqlite";
        WT_DSN = "./database.db";
      }
      // cfg.settings;

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = lib.getExe cfg.package;
        Restart = "always";
        StateDirectory = stateDir;
        WorkingDirectory = "%S/${stateDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ bhankas ];
}

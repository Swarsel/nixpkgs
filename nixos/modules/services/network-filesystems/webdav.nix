{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.webdav;
  format = pkgs.formats.yaml { };
in
{
  options = {
    services.webdav = {
      enable = lib.mkEnableOption "WebDAV server";
      package = lib.mkPackageOption pkgs "webdav" { };

      configFile = lib.mkOption {
        default = format.generate "webdav.yaml" cfg.settings;
        defaultText = "Config file generated from services.webdav.settings";

        description = ''
          Path to config file. If this option is set, it will override any
          configuration done in options.services.webdav.settings.
        '';

        example = "/etc/webdav/config.yaml";
        type = lib.types.path;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file as defined in {manpage}`systemd.exec(5)`.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      group = lib.mkOption {
        default = "webdav";
        description = "Group under which WebDAV runs.";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Attrset that is converted and passed as config file. Available options
          can be found at
          [here](https://github.com/hacdias/webdav).

          This program supports reading username and password configuration
          from environment variables, so it's strongly recommended to store
          username and password in a separate
          [EnvironmentFile](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=).
          This prevents adding secrets to the world-readable Nix store.
        '';

        example = lib.literalExpression ''
          {
              address = "0.0.0.0";
              port = 8080;
              directory = "/srv/public";
              permissions = "R";
              users = [
                {
                  username = "{env}ENV_USERNAME";
                  password = "{env}ENV_PASSWORD";
                }
              ];
          }
        '';

        type = format.type;
      };

      user = lib.mkOption {
        default = "webdav";
        description = "User account under which WebDAV runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.webdav = {
      after = [ "network.target" ];
      description = "WebDAV server";

      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${lib.getExe cfg.package} -c ${cfg.configFile}";
        Group = cfg.group;
        Restart = "on-failure";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "webdav") {
      webdav.gid = config.ids.gids.webdav;
    };

    users.users = lib.mkIf (cfg.user == "webdav") {
      webdav = {
        description = "WebDAV daemon user";
        group = cfg.group;
        uid = config.ids.uids.webdav;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ pmy ];
}

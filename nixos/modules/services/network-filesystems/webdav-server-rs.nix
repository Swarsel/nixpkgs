{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.webdav-server-rs;
  format = pkgs.formats.toml { };
  settings = lib.recursiveUpdate {
    server.gid = config.users.groups."${cfg.group}".gid;
    server.uid = config.users.users."${cfg.user}".uid;
  } cfg.settings;
in
{
  options = {
    services.webdav-server-rs = {
      enable = lib.mkEnableOption "WebDAV server";

      configFile = lib.mkOption {
        default = format.generate "webdav-server.toml" settings;
        defaultText = "Config file generated from services.webdav-server-rs.settings";

        description = ''
          Path to config file. If this option is set, it will override any
          configuration done in services.webdav-server-rs.settings.
        '';

        example = "/etc/webdav-server.toml";
        type = lib.types.path;
      };

      debug = lib.mkOption {
        default = false;
        description = "Enable debug mode.";
        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "webdav";
        description = "Group to run under when setuid is not enabled.";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Attrset that is converted and passed as config file. Available
          options can be found at
          [here](https://github.com/miquels/webdav-server-rs/blob/master/webdav-server.toml).
        '';

        example = lib.literalExpression ''
          {
            server.listen = [ "0.0.0.0:4918" "[::]:4918" ];
            accounts = {
              auth-type = "htpasswd.default";
              acct-type = "unix";
            };
            htpasswd.default = {
              htpasswd = "/etc/htpasswd";
            };
            location = [
              {
                route = [ "/public/*path" ];
                directory = "/srv/public";
                handler = "filesystem";
                methods = [ "webdav-ro" ];
                autoindex = true;
                auth = "false";
              }
              {
                route = [ "/user/:user/*path" ];
                directory = "~";
                handler = "filesystem";
                methods = [ "webdav-rw" ];
                autoindex = true;
                auth = "true";
                setuid = true;
              }
            ];
          }
        '';

        type = format.type;
      };

      user = lib.mkOption {
        default = "webdav";
        description = "User to run under when setuid is not enabled.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasAttr cfg.user config.users.users && config.users.users."${cfg.user}".uid != null;
        message = "users.users.${cfg.user} and users.users.${cfg.user}.uid must be defined.";
      }
      {
        assertion =
          lib.hasAttr cfg.group config.users.groups && config.users.groups."${cfg.group}".gid != null;

        message = "users.groups.${cfg.group} and users.groups.${cfg.group}.gid must be defined.";
      }
    ];

    systemd.services.webdav-server-rs = {
      after = [ "network.target" ];
      description = "WebDAV server";

      serviceConfig = {
        CapabilityBoundingSet = [
          "CAP_SETUID"
          "CAP_SETGID"
        ];

        ExecPaths = [ "/nix/store" ];
        ExecStart = "${pkgs.webdav-server-rs}/bin/webdav-server ${lib.optionalString cfg.debug "--debug"} -c ${cfg.configFile}";
        NoExecPaths = [ "/" ];
        # This program actively detects if it is running in root user account
        # when it starts and uses root privilege to switch process uid to
        # respective unix user when a user logs in.  Maybe we can enable
        # DynamicUser in the future when it's able to detect CAP_SETUID and
        # CAP_SETGID capabilities.
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "webdav") {
      webdav.gid = config.ids.gids.webdav;
    };

    users.users = lib.optionalAttrs (cfg.user == "webdav") {
      webdav = {
        description = "WebDAV user";
        group = cfg.group;
        uid = config.ids.uids.webdav;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ pmy ];
}

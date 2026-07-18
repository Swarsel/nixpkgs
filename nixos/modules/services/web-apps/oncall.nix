{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.oncall;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "oncall_extra_settings.yaml" cfg.settings;

in
{
  options.services.oncall = {

    enable = lib.mkEnableOption "Oncall web app";
    package = lib.mkPackageOption pkgs "oncall" { };

    database.createLocally = lib.mkEnableOption "Create the database and database user locally." // {
      default = true;
    };

    secretFile = lib.mkOption {
      description = ''
        A YAML file containing secrets such as database or user passwords.
        Some variables that can be considered secrets are:

        - db.conn.kwargs.password:
          Password used to authenticate to the database.

        - session.encrypt_key:
          Key for encrypting/signing session cookies.
          Change to random long values in production.

        - session.sign_key:
          Key for encrypting/signing session cookies.
          Change to random long values in production.
      '';

      example = "/run/keys/oncall-dbpassword";
      type = lib.types.externalPath;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Extra configuration options to append or override.
        For available and default option values see
        [upstream configuration file](https://github.com/linkedin/oncall/blob/master/configs/config.yaml)
        and the administration part in the
        [offical documentation](https://oncall.tools/docs/admin_guide.html).
      '';

      type = lib.types.submodule {
        options = {
          db.conn = {
            kwargs = {
              database = lib.mkOption {
                default = "oncall";
                description = "Database name.";
                type = lib.types.str;
              };

              host = lib.mkOption {
                default = "localhost";
                description = "Database host.";
                type = lib.types.str;
              };

              user = lib.mkOption {
                default = "oncall";
                description = "Database user.";
                type = lib.types.str;
              };
            };

            require_auth = lib.mkOption {
              default = true;

              description = ''
                Whether authentication is required to access the web app.
              '';

              type = lib.types.bool;
            };

            str = lib.mkOption {
              default = "%(scheme)s://%(user)s@%(host)s:%(port)s/%(database)s?charset=%(charset)s&unix_socket=/run/mysqld/mysqld.sock";

              description = ''
                Database connection scheme. The default specifies the
                connection through a local socket.
              '';

              type = lib.types.str;
            };
          };

          oncall_host = lib.mkOption {
            default = "localhost";
            description = "FQDN for the Oncall instance.";
            type = lib.types.str;
          };
        };

        freeformType = settingsFormat.type;
      };
    };

  };

  config = lib.mkIf cfg.enable {

    services.mysql = lib.mkIf cfg.database.createLocally {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.settings.db.conn.kwargs.database ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.settings.db.conn.kwargs.database}.*" = "ALL PRIVILEGES";
          };

          name = cfg.settings.db.conn.kwargs.user;
        }
      ];
    };

    services.nginx = {
      enable = lib.mkDefault true;

      virtualHosts."${cfg.settings.oncall_host}".locations = {
        "/".extraConfig = "uwsgi_pass unix://${config.services.uwsgi.runDir}/oncall.sock;";
      };
    };

    # Disable debug, only needed for development
    services.oncall.settings = lib.mkMerge [
      {
        auth.debug = lib.mkDefault false;
        debug = lib.mkDefault false;
      }
    ];

    services.uwsgi = {
      enable = true;

      instance = {
        type = "emperor";

        vassals = {
          oncall = {
            buffer-size = 32768;
            chmod-socket = "770";

            env = [
              "PYTHONPATH=${pkgs.oncall.pythonPath}"
              (
                "ONCALL_EXTRA_CONFIG="
                + (lib.concatStringsSep "," (
                  [ configFile ] ++ lib.optional (cfg.secretFile != null) cfg.secretFile
                ))
              )
              "STATIC_ROOT=/var/lib/oncall"
            ];

            immediate-gid = "nginx";
            module = "oncall.app:get_wsgi_app()";
            pyargv = "${pkgs.oncall}/share/configs/config.yaml";
            socket = "${config.services.uwsgi.runDir}/oncall.sock";
            socketGroup = "nginx";
            type = "normal";
          };
        };
      };

      plugins = [ "python3" ];
      user = "oncall";
    };

    systemd = {
      services = {
        oncall-setup-database = lib.mkIf cfg.database.createLocally {
          after = [ "mysql.service" ];
          description = "Set up Oncall database";
          requiredBy = [ "uwsgi.service" ];

          script =
            let
              mysql = "${lib.getExe' config.services.mysql.package "mysql"}";
            in
            ''
              if [ ! -f /var/lib/oncall/.dbexists ]; then
                # Load database schema provided with package
                ${mysql} ${cfg.settings.db.conn.kwargs.database} < ${cfg.package}/share/db/schema.v0.sql
                ${mysql} ${cfg.settings.db.conn.kwargs.database} < ${cfg.package}/share/db/schema-update.v0-1602184489.sql
                touch /var/lib/oncall/.dbexists
              fi
            '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };
        };

        uwsgi.serviceConfig.StateDirectory = "oncall";
      };
    };

    users.users.oncall = {
      group = "nginx";
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}

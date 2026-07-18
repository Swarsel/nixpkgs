{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.inventree;
  pkg = cfg.package;

  mysqlLocal = cfg.database.createLocally && cfg.database.dbtype == "mysql";
  pgsqlLocal = cfg.database.createLocally && cfg.database.dbtype == "postgresql";

  manage = pkgs.writeShellScriptBin "inventree-manage" ''
    set -a
    ${lib.toShellVars cfg.settings}
    ${lib.optionalString (
      cfg.database.passwordFile != null
    ) ''INVENTREE_DB_PASSWORD="$(<${lib.escapeShellArg cfg.database.passwordFile})"''}
    set +a

    pushd ${lib.escapeShellArg cfg.dataDir}
    expectedUser=${lib.escapeShellArg cfg.user}
    sudo=()
    if [[ "$USER" != "$expectedUser" ]]; then
      ${
        if config.security.sudo.enable then
          ''sudo+=(${config.security.wrapperDir}/sudo -u "$expectedUser" -E)''
        else
          ''printf 'Aborting, inventree-manage must be run as user %s\n!' "$expectedUser" >&2; exit 2''
      }
    fi
    exec "''${sudo[@]}" ${cfg.package}/bin/inventree "$@"
  '';

in
{
  options.services.inventree = {
    enable = lib.mkEnableOption "inventree";

    package = lib.mkOption {
      default = pkgs.inventree;
      defaultText = lib.literalExpression "pkgs.inventree";
      description = "Which package to use for the InvenTree instance.";
      type = lib.types.package;
    };

    adminPasswordFile = lib.mkOption {
      default = null;
      description = "Path to a file containing admin password";
      example = "/run/keys/inventree-password";
      type = lib.types.nullOr lib.types.path;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/inventree";
      description = "Inventree's data storage path.  Will be `/var/lib/inventree` by default.";
      type = lib.types.str;
    };

    database = {
      createLocally = lib.mkOption {
        default = true;
        description = "Create the database and database user locally.";
        type = lib.types.bool;
      };

      dbhost = lib.mkOption {
        default = null;
        description = "Database host or socket path.";
        example = "localhost";
        type = lib.types.nullOr lib.types.str;
      };

      dbname = lib.mkOption {
        default = "inventree";
        description = "Database name.";
        type = lib.types.str;
      };

      dbport = lib.mkOption {
        default = null;
        description = "Database host port.";
        example = 5432;
        type = lib.types.nullOr lib.types.port;
      };

      dbtype = lib.mkOption {
        default = "postgresql";
        description = "Database type.";

        type = lib.types.nullOr (
          lib.types.enum [
            "postgresql"
            "mysql"
          ]
        );
      };

      dbuser = lib.mkOption {
        default = "inventree";
        description = "Database username.";
        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        default = null;

        description = ''
          A file containing the password corresponding to
          <option>database.dbuser</option>.
        '';

        example = "/run/keys/inventree-dbpassword";
        type = with lib.types; nullOr path;
      };
    };

    domain = lib.mkOption {
      default = "localhost";

      description = ''
        The INVENTREE_SITE_URL option defines the base URL for the
        InvenTree server. This is a critical setting, and it is required
        for correct operation of the server. If not specified, the
        server will attempt to determine the site URL automatically -
        but this may not always be correct!

        The site URL is the URL that users will use to access the
        InvenTree server. For example, if the server is accessible at
        `https://inventree.example.com`, the site URL should be set to
        `https://inventree.example.com`. Note that this is not
        necessarily the same as the internal URL that the server is
        running on - the internal URL will depend entirely on your
        server configuration and may be obscured by a reverse proxy or
        other such setup.
      '';

      example = "inventree.example.com";
      type = lib.types.str;
    };

    group = lib.mkOption {
      default = "inventree";
      description = "Group under which InvenTree runs.";
      type = lib.types.str;
    };

    secretKeyFile = lib.mkOption {
      default = "${cfg.dataDir}/secret_key.txt";
      defaultText = lib.literalExpression ''"''${cfg.dataDir}/secret_key.txt"'';

      description = ''
        Path to a file containing the secret key
      '';

      example = "/run/keys/inventree-secret-key";
      type = lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        InvenTree config options.

        See [the documentation](https://docs.inventree.org/en/stable/start/config/) for available options.
      '';

      example = {
        INVENTREE_CACHE_ENABLED = true;
        INVENTREE_CACHE_HOST = "localhost";
        INVENTREE_EMAIL_HOST = "smtp.example.com";
        INVENTREE_EMAIL_PORT = 25;
      };

      type =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            path
            str
          ])
        );
    };

    user = lib.mkOption {
      default = "inventree";
      description = "User under which InvenTree runs.";
      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ manage ];

        services.inventree.settings = {
          INVENTREE_ADMIN_EMAIL = lib.mkDefault "admin@${cfg.domain}";
          INVENTREE_ADMIN_PASSWORD_FILE = lib.mkDefault cfg.adminPasswordFile;
          INVENTREE_ADMIN_USER = lib.mkDefault "admin";
          INVENTREE_AUTO_UPDATE = lib.mkDefault "false";
          INVENTREE_BACKUP_DIR = lib.mkDefault "${cfg.dataDir}/data/backups";
          INVENTREE_CONFIG_FILE = lib.mkDefault "${cfg.dataDir}/config/config.yaml";
          INVENTREE_DB_ENGINE = cfg.database.dbtype;
          INVENTREE_DB_HOST = cfg.database.dbhost;
          INVENTREE_DB_NAME = cfg.database.dbname;
          INVENTREE_DB_PORT = if cfg.database.dbport != null then toString cfg.database.dbport else null;
          INVENTREE_DB_USER = cfg.database.dbuser;
          INVENTREE_MEDIA_ROOT = lib.mkDefault "${cfg.dataDir}/data/media";
          INVENTREE_OIDC_PRIVATE_KEY_FILE = lib.mkDefault "${cfg.dataDir}/config/oidc_private_key.txt";
          INVENTREE_PLUGIN_DIR = lib.mkDefault "${cfg.dataDir}/data/plugins";
          INVENTREE_PLUGIN_FILE = lib.mkDefault "${cfg.dataDir}/data/plugins/plugins.txt";
          INVENTREE_SECRET_KEY_FILE = lib.mkDefault cfg.secretKeyFile;
          INVENTREE_SITE_URL = lib.mkDefault "http://${cfg.domain}";
          INVENTREE_STATIC_ROOT = lib.mkDefault "${cfg.package}/lib/inventree/static";
        };

        services.mysql = lib.mkIf mysqlLocal {
          enable = true;
          package = lib.mkDefault pkgs.mariadb;
          ensureDatabases = [ cfg.database.dbname ];

          ensureUsers = [
            {
              ensurePermissions = {
                "${cfg.database.dbname}.*" = "ALL PRIVILEGES";
              };

              name = cfg.database.dbuser;
            }
          ];
        };

        services.nginx.enable = true;

        services.nginx.virtualHosts.${cfg.domain} = {
          locations =
            let
              unixPath = config.systemd.sockets.inventree-server.socketConfig.ListenStream;
            in
            {
              "/" = {
                extraConfig = ''
                  proxy_set_header X-Forwarded-By $server_addr:$server_port;
                  proxy_set_header CLIENT_IP $remote_addr;

                  proxy_pass_request_headers on;

                  proxy_redirect off;

                  client_max_body_size 100M;

                  proxy_buffering off;
                  proxy_request_buffering off;
                '';

                proxyPass = "http://unix:${unixPath}";
                # recommendedProxySettings sets the standard headers (Host, X-Forwarded-*), so
                # don't also set them via proxy_set_header in extraConfig below. Nginx would then
                # send Host twice and Django rejects it with DisallowedHost. Enabled per-location
                # so it works even if the host's global recommendedProxySettings is off.
                recommendedProxySettings = true;
              };

              "/auth" = {
                extraConfig = ''
                  internal;
                  proxy_pass_request_body off;
                  proxy_set_header Content-Length "";
                  proxy_set_header X-Original-URI $request_uri;
                '';

                proxyPass = "http://unix:${unixPath}:/auth/";
                # same reasoning as "/"; this subrequest also reaches Django
                recommendedProxySettings = true;
              };

              "/media/" = {
                alias = "${cfg.settings.INVENTREE_MEDIA_ROOT}/";

                extraConfig = ''
                  auth_request /auth;
                  add_header Content-disposition "attachment";
                '';
              };

              "/static/" = {
                alias = "${cfg.settings.INVENTREE_STATIC_ROOT}/";

                extraConfig = ''
                  autoindex on;

                  # Caching settings
                  expires 30d;
                  add_header Pragma public;
                  add_header Cache-Control "public";
                '';
              };
            };
        };

        services.postgresql = lib.mkIf pgsqlLocal {
          enable = true;
          ensureDatabases = [ cfg.database.dbname ];

          ensureUsers = [
            {
              ensureDBOwnership = true;
              name = cfg.database.dbuser;
            }
          ];
        };

        systemd.services.inventree-qcluster = {
          description = "InvenTree qcluster server";
          environment = cfg.settings;
          partOf = [ "inventree.target" ];
          requiredBy = [ "inventree.target" ];

          script = ''
            ${
              lib.optionalString (cfg.database.passwordFile != null) ''
                INVENTREE_DB_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/db_password")
              ''
            } \
            exec ${pkg}/bin/inventree qcluster
          '';

          serviceConfig = {
            Group = cfg.group;
            PrivateTmp = true;
            StateDirectory = "inventree";
            User = cfg.user;
          }
          // lib.optionalAttrs (cfg.database.passwordFile != null) {
            LoadCredential = "db_password:${cfg.database.passwordFile}";
          };

          wantedBy = [ "inventree.target" ];
        };

        systemd.services.inventree-server = {
          description = "Inventree Gunicorn service";
          environment = cfg.settings;
          partOf = [ "inventree.target" ];
          requiredBy = [ "inventree.target" ];

          script = ''
            ${
              lib.optionalString (cfg.database.passwordFile != null) ''
                INVENTREE_DB_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/db_password")
              ''
            } \
            exec ${pkg}/bin/gunicorn InvenTree.wsgi
          '';

          serviceConfig = {
            Group = cfg.group;
            PrivateTmp = true;
            StateDirectory = "inventree";
            User = cfg.user;
          }
          // lib.optionalAttrs (cfg.database.passwordFile != null) {
            LoadCredential = "db_password:${cfg.database.passwordFile}";
          };
        };

        systemd.services.inventree-setup = {
          after = lib.optional mysqlLocal "mysql.service" ++ lib.optional pgsqlLocal "postgresql.target";

          before = [
            "inventree-server.service"
            "inventree-qcluster.service"
          ];

          description = "Inventree setup";
          environment = cfg.settings;
          partOf = [ "inventree.target" ];
          requires = lib.optional mysqlLocal "mysql.service" ++ lib.optional pgsqlLocal "postgresql.target";

          script = ''
            set -euo pipefail
            umask u=rwx,g=,o=

            ${
              lib.optionalString (cfg.database.passwordFile != null) ''
                INVENTREE_DB_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/db_password")
              ''
            } \
            exec ${pkg}/bin/inventree migrate
          '';

          serviceConfig = {
            Group = cfg.group;
            PrivateTmp = true;
            RemainAfterExit = true;
            Type = "oneshot";
            User = cfg.user;
          }
          // lib.optionalAttrs (cfg.database.passwordFile != null) {
            LoadCredential = "db_password:${cfg.database.passwordFile}";
          };

          wantedBy = [ "inventree.target" ];
        };

        systemd.sockets.inventree-server = {
          partOf = [ "inventree.target" ];
          socketConfig.ListenStream = "/run/inventree/gunicorn.socket";
          wantedBy = [ "sockets.target" ];
        };

        systemd.targets.inventree = {
          after = [ "network-online.target" ];
          description = "Target for all InvenTree services";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };

        systemd.tmpfiles.rules = (
          map (dir: "d ${dir} 0755 inventree inventree") [
            "${cfg.dataDir}"
            "${cfg.dataDir}/config"
            "${cfg.dataDir}/data"
            "${cfg.dataDir}/data/media"
            "${cfg.dataDir}/data/backups"
            "${cfg.dataDir}/data/plugins"
          ]
        );

        users = lib.optionalAttrs (cfg.user == cfg.user) {
          groups.${cfg.group}.members = [ cfg.user ];

          users.${cfg.user} = {
            group = cfg.group;
            home = cfg.dataDir;
            isSystemUser = true;
          };
        };
      }
    ]
  );

  meta.buildDocsInSandbox = false;

  meta.maintainers = with lib.maintainers; [
    kurogeek
  ];
}

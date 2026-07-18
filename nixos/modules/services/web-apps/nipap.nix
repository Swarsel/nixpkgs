{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nipap;
  iniFmt = pkgs.formats.ini { };

  configFile = iniFmt.generate "nipap.conf" cfg.settings;

  defaultUser = "nipap";
  defaultAuthBackend = "local";
  dataDir = "/var/lib/nipap";

  defaultServiceConfig = {
    Group = config.users.users."${cfg.user}".group;
    Restart = "on-failure";
    RestartSec = 30;
    User = cfg.user;
    WorkingDirectory = dataDir;
  };

  escapedHost = host: if lib.hasInfix ":" host then "[${host}]" else host;
in
{
  options.services.nipap = {
    enable = lib.mkEnableOption "global Neat IP Address Planner (NIPAP) configuration";

    authBackendSettings = lib.mkOption {
      default = {
        "${defaultAuthBackend}" = {
          db_path = "${dataDir}/local_auth.db";
          type = "SqliteAuth";
        };
      };

      description = ''
        auth.backends options to set in /etc/nipap/nipap.conf.
      '';

      type = lib.types.submodule {
        freeformType = iniFmt.type;
      };
    };

    nipap-www = {
      enable = lib.mkEnableOption "nipap-www server";
      package = lib.mkPackageOption pkgs "nipap-www" { };

      host = lib.mkOption {
        default = "::";
        description = "Host to bind to.";
        type = lib.types.nullOr lib.types.str;
      };

      port = lib.mkOption {
        default = 21337;
        description = "Port to bind to.";
        type = lib.types.nullOr lib.types.port;
      };

      umask = lib.mkOption {
        default = "0";
        description = "umask for files written by Gunicorn, including UNIX socket.";
        type = lib.types.str;
      };

      unixSocket = lib.mkOption {
        default = null;
        description = "Path to UNIX socket to bind to.";
        example = "/run/nipap/nipap-www.sock";
        type = lib.types.nullOr lib.types.str;
      };

      workers = lib.mkOption {
        default = 4;
        description = "Number of worker processes for Gunicorn to fork.";
        type = lib.types.int;
      };

      xmlrpcURIFile = lib.mkOption {
        default = null;
        description = "Path to file containing XMLRPC URI for use by web UI - this is a secret, since it contains auth credentials. If null, it will be initialized assuming that the auth database is local.";
        type = lib.types.nullOr lib.types.path;
      };
    };

    nipapd = {
      enable = lib.mkEnableOption "nipapd server";
      package = lib.mkPackageOption pkgs "nipap" { };

      database.createLocally = lib.mkOption {
        default = true;
        description = "Create a nipap database automatically.";
        type = lib.types.bool;
      };
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration options to set in /etc/nipap/nipap.conf.
      '';

      type = lib.types.submodule {
        options = {
          auth = {
            auth_cache_timeout = lib.mkOption {
              default = 3600;
              description = "Seconds to store cached auth entries for.";
              type = lib.types.int;
            };

            default_backend = lib.mkOption {
              default = defaultAuthBackend;
              description = "Name of auth backend to use by default.";
              type = lib.types.str;
            };
          };

          nipapd = {
            db_host = lib.mkOption {
              default = "";
              description = "PostgreSQL host to connect to. Empty means use UNIX socket.";
              type = lib.types.str;
            };

            db_name = lib.mkOption {
              default = cfg.user;
              defaultText = defaultUser;
              description = "Name of database to use on PostgreSQL server.";
              type = lib.types.str;
            };

            debug = lib.mkOption {
              default = false;
              description = "Enable debug logging.";
              type = lib.types.bool;
            };

            foreground = lib.mkOption {
              default = true;
              description = "Remain in foreground rather than forking to background.";
              type = lib.types.bool;
            };

            listen = lib.mkOption {
              default = "::1";
              description = "IP address to bind nipapd to.";
              type = lib.types.str;
            };

            port = lib.mkOption {
              default = 1337;
              description = "Port to bind nipapd to.";
              type = lib.types.port;
            };
          };
        };

        freeformType = iniFmt.type;
      };
    };

    user = lib.mkOption {
      default = defaultUser;
      description = "User to use for running NIPAP services.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.etc."nipap/nipap.conf" = {
          source = configFile;
        };

        environment.systemPackages = [
          cfg.nipapd.package
        ];

        services.nipap.nipap-www.enable = lib.mkDefault true;
        services.nipap.nipapd.enable = lib.mkDefault true;

        services.nipap.settings = lib.attrsets.mapAttrs' (name: value: {
          inherit value;
          name = "auth.backends.${name}";
        }) cfg.authBackendSettings;

        systemd.tmpfiles.rules = [
          "d '${dataDir}' - ${cfg.user} ${config.users.users."${cfg.user}".group} - -"
        ];
      }
      (lib.mkIf (cfg.user == defaultUser) {
        users.groups."${defaultUser}" = { };

        users.users."${defaultUser}" = {
          group = defaultUser;
          home = dataDir;
          isSystemUser = true;
        };
      })
      (lib.mkIf (cfg.nipapd.enable && cfg.nipapd.database.createLocally) {
        services.postgresql = {
          enable = true;
          ensureDatabases = [ cfg.settings.nipapd.db_name ];

          ensureUsers = [
            {
              name = cfg.user;
            }
          ];

          extensions = ps: with ps; [ ip4r ];
        };

        systemd.services.postgresql.serviceConfig.ExecStartPost =
          let
            sqlFile = pkgs.writeText "nipapd-setup.sql" ''
              CREATE EXTENSION IF NOT EXISTS ip4r;

              ALTER SCHEMA public OWNER TO "${cfg.user}";
              ALTER DATABASE "${cfg.settings.nipapd.db_name}" OWNER TO "${cfg.user}";
            '';
          in
          [
            ''
              ${lib.getExe' config.services.postgresql.finalPackage "psql"} -d "${cfg.settings.nipapd.db_name}" -f "${sqlFile}"
            ''
          ];
      })
      (lib.mkIf cfg.nipapd.enable {
        systemd.services.nipapd =
          let
            pkg = cfg.nipapd.package;
          in
          {
            after = [
              "network.target"
              "systemd-tmpfiles-setup.service"
            ]
            ++ lib.optional (cfg.settings.nipapd.db_host == "") "postgresql.target";

            description = "Neat IP Address Planner";

            preStart = lib.optionalString (cfg.settings.auth.default_backend == defaultAuthBackend) ''
              # Create/upgrade local auth database
              umask 077
              ${pkg}/bin/nipap-passwd create-database >/dev/null 2>&1
              ${pkg}/bin/nipap-passwd upgrade-database >/dev/null 2>&1
            '';

            requires = lib.optional (cfg.settings.nipapd.db_host == "") "postgresql.target";

            serviceConfig = defaultServiceConfig // {
              ExecStart = ''
                ${pkg}/bin/nipapd \
                  --auto-install-db \
                  --auto-upgrade-db \
                  --foreground \
                  --no-pid-file
              '';

              KillSignal = "SIGINT";
            };

            wantedBy = [ "multi-user.target" ];
          };
      })
      (lib.mkIf cfg.nipap-www.enable {
        assertions = [
          {
            assertion =
              cfg.nipap-www.xmlrpcURIFile == null -> cfg.settings.auth.default_backend == defaultAuthBackend;

            message = "If no XMLRPC URI secret file is specified, then the default auth backend must be in use to automatically generate credentials.";
          }
        ];

        # Ensure that _something_ exists in the [www] group.
        services.nipap.settings.www = lib.mkDefault { };

        systemd.services.nipap-www =
          let
            pkg = cfg.nipap-www.package;
          in
          {
            after = [
              "network.target"
              "systemd-tmpfiles-setup.service"
            ]
            ++ lib.optional cfg.nipapd.enable "nipapd.service";

            description = "Neat IP Address Planner web server";

            environment = {
              PYTHONPATH = pkg.pythonPath;
            };

            script =
              let
                bind =
                  if cfg.nipap-www.unixSocket != null then
                    "unix:${cfg.nipap-www.unixSocket}"
                  else
                    "${escapedHost cfg.nipap-www.host}:${toString cfg.nipap-www.port}";
                generateXMLRPC = cfg.nipap-www.xmlrpcURIFile == null;
                xmlrpcURIFile = if generateXMLRPC then "${dataDir}/www_xmlrpc_uri" else cfg.nipap-www.xmlrpcURIFile;
              in
              ''
                test -f "${dataDir}/www_secret" || {
                  umask 0077
                  ${pkg.python}/bin/python -c "import secrets; print(secrets.token_hex())" > "${dataDir}/www_secret"
                }
                export FLASK_SECRET_KEY="$(cat "${dataDir}/www_secret")"

                # Ensure that we have an XMLRPC URI.
                ${
                  if generateXMLRPC then
                    ''
                      test -f "${dataDir}/www_xmlrpc_uri" || {
                        umask 0077
                        www_password="$(${pkg.python}/bin/python -c "import secrets; print(secrets.token_hex())")"
                        ${cfg.nipapd.package}/bin/nipap-passwd add --username nipap-www --password "''${www_password}" --name "User account for the web UI" --trusted

                        echo "http://nipap-www@${defaultAuthBackend}:''${www_password}@${escapedHost cfg.settings.nipapd.listen}:${toString cfg.settings.nipapd.port}" > "${xmlrpcURIFile}"
                      }
                    ''
                  else
                    ""
                }
                export FLASK_XMLRPC_URI="$(cat "${xmlrpcURIFile}")"

                exec "${pkg.gunicorn}/bin/gunicorn" \
                  --preload --workers ${toString cfg.nipap-www.workers} \
                  --pythonpath "${pkg}/${pkg.python.sitePackages}" \
                  --bind ${bind} --umask ${cfg.nipap-www.umask} \
                  "nipapwww:create_app()"
              '';

            serviceConfig = defaultServiceConfig;
            wantedBy = [ "multi-user.target" ];
          };
      })
    ]
  );

  meta.maintainers = with lib.maintainers; [ lukegb ];
}

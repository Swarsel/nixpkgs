{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.kimai;
  eachSite = cfg.sites;
  user = "kimai";
  webserver = config.services.${cfg.webserver};
  stateDir = hostName: "/var/lib/kimai/${hostName}";

  pkg =
    hostName: cfg:
    pkgs.stdenv.mkDerivation rec {
      installPhase = ''
        mkdir -p $out
        cp -r * $out/

        # Symlink .env file. This will be dynamically created at the service
        # startup.
        ln -sf ${stateDir hostName}/.env $out/share/php/kimai/.env

        # Symlink the var/ folder
        # TODO: we may have to symlink individual folders if we want to also
        # manage plugins from Nix.
        rm -rf $out/share/php/kimai/var
        ln -s ${stateDir hostName} $out/share/php/kimai/var

        # Symlink local.yaml.
        ln -s ${kimaiConfig hostName cfg} $out/share/php/kimai/config/packages/local.yaml
      '';

      pname = "kimai-${hostName}";
      src = cfg.package;
      version = src.version;
    };

  kimaiConfig =
    hostName: cfg:
    pkgs.writeTextFile {
      name = "kimai-config-${hostName}.yaml";
      text = generators.toYAML { } cfg.settings;
    };

  siteOpts =
    {
      config,
      lib,
      name,
      ...
    }:
    {
      options = {
        package = mkPackageOption pkgs "kimai" { };

        database = {
          charset = mkOption {
            default = "utf8mb4";
            description = "Database charset.";
            type = types.str;
          };

          createLocally = mkOption {
            default = true;
            description = "Create the database and database user locally.";
            type = types.bool;
          };

          host = mkOption {
            default = "localhost";
            description = "Database host address.";
            type = types.str;
          };

          name = mkOption {
            default = "kimai";
            description = "Database name.";
            type = types.str;
          };

          passwordFile = mkOption {
            default = null;

            description = ''
              A file containing the password corresponding to
              {option}`database.user`.
            '';

            example = "/run/keys/kimai-dbpassword";
            type = types.nullOr types.path;
          };

          port = mkOption {
            default = 3306;
            description = "Database host port.";
            type = types.port;
          };

          serverVersion = mkOption {
            default = null;

            description = ''
              MySQL *exact* version string. Not used if `createdLocally` is set,
              but must be set otherwise. See
              <https://www.kimai.org/documentation/installation.html#column-table_name-in-where-clause-is-ambiguous>
              for how to set this value, especially if you're using MariaDB.
            '';

            type = types.nullOr types.str;
          };

          socket = mkOption {
            default = null;
            defaultText = literalExpression "/run/mysqld/mysqld.sock";
            description = "Path to the unix socket file to use for authentication.";
            type = types.nullOr types.path;
          };

          user = mkOption {
            default = "kimai";
            description = "Database user.";
            type = types.str;
          };
        };

        environmentFile = mkOption {
          default = null;

          description = ''
            Securely pass environment variabels to Kimai. This can be used to
            set other environement variables such as MAILER_URL.
          '';

          example = "/run/secrets/kimai.env";
          type = types.nullOr types.path;
        };

        poolConfig = mkOption {
          default = {
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.max_requests" = 500;
            "pm.max_spare_servers" = 4;
            "pm.min_spare_servers" = 2;
            "pm.start_servers" = 2;
          };

          description = ''
            Options for the Kimai PHP pool. See the documentation on `php-fpm.conf`
            for details on configuration directives.
          '';

          type =
            with types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);
        };

        settings = mkOption {
          default = { };

          description = ''
            Structural Kimai's local.yaml configuration.
            Refer to <https://www.kimai.org/documentation/local-yaml.html#localyaml>
            for details.
          '';

          example = literalExpression ''
            {
              kimai = {
                timesheet = {
                  rounding = {
                    default = {
                      begin = 15;
                      end = 15;
                    };
                  };
                };
              };
            }
          '';

          type = types.attrsOf types.anything;
        };
      };
    };
in
{
  # interface
  options = {
    services.kimai = {
      sites = mkOption {
        default = { };
        description = "Specification of one or more Kimai sites to serve";
        type = types.attrsOf (types.submodule siteOpts);
      };

      webserver = mkOption {
        default = "nginx";

        description = ''
          The webserver to configure for the PHP frontend.

          At the moment, only `nginx` is supported. PRs are welcome for support
          for other web servers.
        '';

        type = types.enum [ "nginx" ];
      };
    };
  };

  # implementation
  config = mkIf (eachSite != { }) (mkMerge [
    {

      assertions =
        (mapAttrsToList (hostName: cfg: {
          assertion = cfg.database.createLocally -> cfg.database.user == user;
          message = ''services.kimai.sites."${hostName}".database.user must be ${user} if the database is to be automatically provisioned'';
        }) eachSite)
        ++ (mapAttrsToList (hostName: cfg: {
          assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
          message = ''services.kimai.sites."${hostName}".database.passwordFile cannot be specified if services.kimai.sites."${hostName}".database.createLocally is set to true.'';
        }) eachSite)
        ++ (mapAttrsToList (hostName: cfg: {
          assertion = !cfg.database.createLocally -> cfg.database.serverVersion != null;
          message = ''services.kimai.sites."${hostName}".database.serverVersion must be specified if services.kimai.sites."${hostName}".database.createLocally is set to false.'';
        }) eachSite);

      services.mysql = mkIf (any (v: v.database.createLocally) (attrValues eachSite)) {
        enable = true;
        package = mkDefault pkgs.mariadb;
        ensureDatabases = mapAttrsToList (hostName: cfg: cfg.database.name) eachSite;

        ensureUsers = mapAttrsToList (hostName: cfg: {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }) eachSite;
      };

      services.phpfpm.pools = mapAttrs' (
        hostName: cfg:
        (nameValuePair "kimai-${hostName}" {
          inherit user;
          group = webserver.group;
          phpPackage = cfg.package.php;

          settings = {
            "listen.group" = webserver.group;
            "listen.owner" = webserver.user;
          }
          // cfg.poolConfig;
        })
      ) eachSite;

    }

    {
      systemd.services = mkMerge [
        (mapAttrs' (
          hostName: cfg:
          (nameValuePair "kimai-init-${hostName}" {
            after = optional cfg.database.createLocally "mysql.service";
            before = [ "phpfpm-kimai-${hostName}.service" ];

            script =
              let
                envFile = "${stateDir hostName}/.env";
                appSecretFile = "${stateDir hostName}/.app_secret";
                mysql = "${config.services.mysql.package}/bin/mysql";

                dbUser = cfg.database.user;
                dbPwd = if cfg.database.passwordFile != null then ":$(cat ${cfg.database.passwordFile})" else "";
                dbHost = cfg.database.host;
                dbPort = toString cfg.database.port;
                dbName = cfg.database.name;
                dbCharset = cfg.database.charset;
                dbUnixSocket = if cfg.database.socket != null then "&unixSocket=${cfg.database.socket}" else "";
                # Note: serverVersion is a shell variable. See below.
                dbUri =
                  "mysql://${dbUser}${dbPwd}@${dbHost}:${dbPort}"
                  + "/${dbName}?charset=${dbCharset}"
                  + "&serverVersion=$serverVersion${dbUnixSocket}";
              in
              ''
                set -eu

                serverVersion=${
                  if !cfg.database.createLocally then
                    cfg.database.serverVersion
                  else
                    # Obtain MySQL version string dynamically from the running
                    # instance. Doctrine ORM's doc said it should be possible to
                    # autodetect this, however Kimai's doc insists that it has to
                    # be set.
                    # https://www.doctrine-project.org/projects/doctrine-dbal/en/latest/reference/configuration.html#mysql
                    # https://stackoverflow.com/q/9558867
                    "$(${mysql} --silent --skip-column-names --execute 'SELECT VERSION();')"
                }

                # Create .env file containing DATABASE_URL and other default
                # variables. Set umask to make sure .env is not readable by
                # unrelated users.
                oldUmask=$(umask)
                umask 177

                if ! [ -e ${appSecretFile} ]; then
                  tr -dc A-Za-z0-9 </dev/urandom | head -c 20 >${appSecretFile}
                fi

                cat >${envFile} <<EOF
                DATABASE_URL=${dbUri}
                MAILER_FROM=kimai@example.com
                MAILER_URL=null://null
                APP_ENV=prod
                APP_SECRET=$(cat ${appSecretFile})
                CORS_ALLOW_ORIGIN=^https?://localhost(:[0-9]+)?\$
                EOF

                umask $oldUmask

                # Ensure that our local.yaml is valid (see kimai:reload command).
                ${pkg hostName cfg}/bin/console lint:yaml --parse-tags \
                  ${pkg hostName cfg}/share/php/kimai/config

                # Before running any further console commands, clear cache. This
                # avoids errors due to old cache getting used with new version
                # of Kimai.
                ${pkg hostName cfg}/bin/console cache:clear --env=prod
                # Then, run kimai:install to ensure database is created or updated.
                # Note that kimai:update is an alias to kimai:install.
                ${pkg hostName cfg}/bin/console kimai:install --no-cache
                # Finally, warm up cache.
                ${pkg hostName cfg}/bin/console cache:warmup --env=prod
              '';

            serviceConfig = {
              EnvironmentFile = [ cfg.environmentFile ];
              Group = webserver.group;
              Type = "oneshot";
              User = user;
            };

            wantedBy = [ "multi-user.target" ];
          })
        ) eachSite)

        (mapAttrs' (
          hostName: cfg:
          (nameValuePair "phpfpm-kimai-${hostName}" {
            serviceConfig = {
              EnvironmentFile = [ cfg.environmentFile ];
            };
          })
        ) eachSite)

        (optionalAttrs (any (v: v.database.createLocally) (attrValues eachSite)) {
          "${cfg.webserver}".after = [ "mysql.service" ];
        })
      ];

      systemd.tmpfiles.rules = flatten (
        mapAttrsToList (hostName: cfg: [
          "d '${stateDir hostName}' 0770 ${user} ${webserver.group} - -"
        ]) eachSite
      );

      users.users.${user} = {
        group = webserver.group;
        isSystemUser = true;
      };
    }

    (mkIf (cfg.webserver == "nginx") {
      services.nginx = {
        enable = true;

        virtualHosts = mapAttrs (hostName: cfg: {
          extraConfig = ''
            index index.php;
          '';

          locations = {
            "/" = {
              extraConfig = ''
                try_files $uri /index.php$is_args$args;
              '';

              priority = 200;
            };

            "~ \\.php$" = {
              extraConfig = ''
                return 404;
              '';

              priority = 800;
            };

            "~ ^/index\\.php(/|$)" = {
              extraConfig = ''
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:${config.services.phpfpm.pools."kimai-${hostName}".socket};
                fastcgi_index index.php;
                include "${config.services.nginx.package}/conf/fastcgi.conf";
                fastcgi_param PATH_INFO $fastcgi_path_info;
                fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
                # Mitigate https://httpoxy.org/ vulnerabilities
                fastcgi_param HTTP_PROXY "";
                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
              '';

              priority = 500;
            };
          };

          root = "${pkg hostName cfg}/share/php/kimai/public";
          serverName = mkDefault hostName;
        }) eachSite;
      };
    })

  ]);
}

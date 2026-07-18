{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.part-db;
  pkg = cfg.package;

  envFile = pkgs.writeText "part-db-env" (
    lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: "${key}=\"${value}\"") cfg.settings)
    + "\n"
  );

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    ;
in
{
  options.services.part-db = {
    enable = mkEnableOption "PartDB";
    package = mkPackageOption pkgs "part-db" { };

    enableNginx = mkOption {
      default = true;

      description = ''
        Whether to enable nginx or not. If enabled, an nginx virtual host will
        be created for access to part-db. If not enabled, then you may use
        `''${config.services.part-db.package}/public` as your document root in
        whichever webserver you wish to setup.
      '';

      type = types.bool;
    };

    enablePostgresql = mkOption {
      default = true;

      description = ''
        Whether to configure the postgresql database for part-db. If enabled,
        a database and user will be created for part-db.
      '';

      type = types.bool;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to a file containing extra Part-DB environment variables in dotenv
        format. This can be used for secrets such as `APP_SECRET` without
        putting them in the Nix store.
      '';

      example = "/run/secrets/part-db.env";
      type = types.nullOr types.path;
    };

    phpPackage = mkPackageOption pkgs "php" { } // {
      apply =
        pkg:
        pkg.buildEnv {
          extraConfig = ''
            memory_limit = 256M;
          '';
        };
    };

    poolConfig = lib.mkOption {
      default = { };

      defaultText = ''
        {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        }
      '';

      description = ''
        Options for the PartDB PHP pool. See the documentation on <literal>php-fpm.conf</literal>
        for details on configuration directives.
      '';

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
          lib.types.bool
        ]
      );
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Options for part-db configuration. Refer to
        <https://github.com/Part-DB/Part-DB-server/blob/master/.env> for
        details on supported values. All <option>_FILE values supported by
        upstream are supported here.
      '';

      example = lib.literalExpression ''
        {
          DATABASE_URL = "postgresql://db_user@localhost/db_name?serverVersion=16.6&charset=utf8&host=/var/run/postgresql";
        }
      '';

      type = lib.types.submodule {
        options = {
          DATABASE_URL = lib.mkOption {
            default = "postgresql://part-db@localhost/part-db?serverVersion=${config.services.postgresql.package.version}&host=/run/postgresql";
            defaultText = "postgresql://part-db@localhost/part-db?serverVersion=\${config.services.postgresql.package.version}&host=/run/postgresql";

            description = ''
              The postgresql database server to connect to.
              Defauls to local postgresql unix socket
            '';

            type = lib.types.str;
          };
        };

        freeformType = lib.types.attrsOf (
          with lib.types;
          oneOf [
            str
            int
            bool
          ]
        );
      };
    };

    virtualHost = mkOption {
      default = "localhost";

      description = ''
        The virtualHost at which you wish part-db to be served.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services = {
      nginx = mkIf cfg.enableNginx {
        enable = true;
        recommendedGzipSettings = lib.mkDefault true;
        recommendedOptimisation = lib.mkDefault true;
        recommendedTlsSettings = lib.mkDefault true;

        virtualHosts.${cfg.virtualHost} = {
          locations = {
            "/" = {
              extraConfig = ''
                add_header Content-Security-Policy "default-src 'self'; script-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; sandbox;" always;
                add_header X-Content-Type-Options "nosniff" always;
                sendfile off;
              '';

              index = "index.php";
              tryFiles = "$uri $uri/ /index.php$is_args$args";
            };

            "= /index.php" = {
              extraConfig = ''
                include ${config.services.nginx.package}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
                fastcgi_param DOCUMENT_ROOT $realpath_root;
                fastcgi_param modHeadersAvailable true; # Avoid sending the security headers twice
                fastcgi_pass unix:${config.services.phpfpm.pools.part-db.socket};
                internal;
              '';
            };

            "~ \\.php$" = {
              return = "404";
            };

            "~* \\.svg$" = {
              extraConfig = ''
                add_header Content-Security-Policy "default-src 'self'; script-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; frame-ancestors 'none'; sandbox;" always;
                add_header X-Content-Type-Options "nosniff" always;
              '';
            };

            "~* ^/media/.*\\.(php[3-8]?|phar|phtml|pht|phps)$" = {
              return = "403";
            };
          };

          root = "${pkg}/public";
        };
      };

      # Required for symphony
      part-db.settings.APP_SHARE_DIR = "/var/lib/part-db/share";

      phpfpm.pools.part-db = {
        group = "part-db";

        phpOptions = ''
          log_errors = on
        '';

        phpPackage = cfg.phpPackage;

        settings = {
          "listen.group" = lib.mkDefault "part-db";
          "listen.mode" = lib.mkDefault "0660";
          "listen.owner" = lib.mkDefault "part-db";
          "pm" = lib.mkDefault "dynamic";
          "pm.max_children" = lib.mkDefault 32;
          "pm.max_requests" = lib.mkDefault 500;
          "pm.max_spare_servers" = lib.mkDefault 4;
          "pm.min_spare_servers" = lib.mkDefault 2;
          "pm.start_servers" = lib.mkDefault 2;
        }
        // cfg.poolConfig;

        user = "part-db";
      };

      postgresql = mkIf cfg.enablePostgresql {
        enable = true;
        ensureDatabases = [ "part-db" ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = "part-db";
          }
        ];
      };
    };

    systemd = {
      services = {
        part-db-migrate = {
          after = [
            "postgresql.target"
            "part-db-setup.service"
          ];

          before = [ "phpfpm-part-db.service" ];

          requires = [
            "postgresql.target"
            "part-db-setup.service"
          ];

          restartTriggers = [
            cfg.package
          ];

          script = ''
            set -euo pipefail
            ${lib.getExe cfg.phpPackage} ${lib.getExe' cfg.package "console"} doctrine:migrations:migrate --no-interaction
          '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
            User = "part-db";
          };

          wantedBy = [ "multi-user.target" ];
        };

        part-db-setup = {
          before = [ "part-db-migrate.service" ];
          restartTriggers = [ envFile ];

          script = ''
            install -Dm0600 -o part-db -g part-db ${envFile} /var/lib/part-db/env.local
          ''
          + lib.optionalString (cfg.environmentFile != null) ''
            cat ${lib.escapeShellArg cfg.environmentFile} >> /var/lib/part-db/env.local
          '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };

          wantedBy = [ "multi-user.target" ];
        };

        phpfpm-part-db = {
          after = [ "part-db-migrate.service" ];

          # ensure nginx can access the php-fpm socket
          postStart = ''
            ${lib.getExe' pkgs.acl "setfacl"} -m 'u:${config.services.nginx.user}:rw' ${config.services.phpfpm.pools.part-db.socket}
          '';

          requires = [
            "part-db-migrate.service"
            "postgresql.target"
          ];
        };
      };

      tmpfiles.settings."part-db" = {
        "/var/cache/part-db/".d = {
          group = "part-db";
          mode = "0750";
          user = "part-db";
        };

        "/var/lib/part-db/".d = {
          group = "part-db";
          mode = "0755";
          user = "part-db";
        };

        "/var/lib/part-db/public/".d = {
          group = "part-db";
          mode = "0755";
          user = "part-db";
        };

        "/var/lib/part-db/public/media/".d = {
          group = "part-db";
          mode = "0755";
          user = "part-db";
        };

        "/var/lib/part-db/share/".d = {
          group = "part-db";
          mode = "0750";
          user = "part-db";
        };

        "/var/lib/part-db/uploads/".d = {
          group = "part-db";
          mode = "0750";
          user = "part-db";
        };

        "/var/log/part-db/".d = {
          group = "part-db";
          mode = "0750";
          user = "part-db";
        };
      };
    };

    users.groups.part-db = { };

    users.users.part-db = {
      group = "part-db";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ felbinger ];
}

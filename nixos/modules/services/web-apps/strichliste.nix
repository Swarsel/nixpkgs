{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.strichliste;

  format = pkgs.formats.yaml { };
  settingsFile = format.generate "strichliste.yaml" {
    parameters.strichliste = cfg.settings;
  };

  unitDependencies =
    lib.optionals (
      lib.hasInfix "pgpsql" cfg.environment.DATABASE_URL
      || lib.hasInfix "postgres" cfg.environment.DATABASE_URL
    ) [ "postgresql.service" ]
    ++ lib.optionals (lib.hasInfix "mysql" cfg.environment.DATABASE_URL) [ "mysql.service" ];
in
{
  options.services.strichliste = {
    enable = mkEnableOption "strichliste, a web based tally sheet.";

    domain = mkOption {
      description = ''
        Domain name used to configure the webserver virtual host.
      '';

      example = "strichliste.example.com";
      type = types.str;
    };

    environment = mkOption {
      default = { };

      description = ''
        Environment variables consumed by Symfony.

        See <https://github.com/strichliste/strichliste-backend/blob/v${cfg.packages.backend.version}/.env.dist> for possible options.
      '';

      type = types.submodule {
        options = {
          APP_CACHE_DIR = mkOption {
            default = "/var/cache/strichliste";

            description = ''
              Directory used for caching.
            '';

            type = types.path;
          };

          APP_ENV = mkOption {
            default = "prod";

            description = ''
              The active environment.
            '';

            type = types.str;
          };

          APP_LOG_DIR = mkOption {
            default = "/var/log/strichliste";

            description = ''
              Directory to write logs.
            '';

            type = types.path;
          };

          CORS_ALLOW_ORIGIN = mkOption {
            default = "^https?://${config.services.strichliste.domain}(:[0-9]+)?$";
            defaultText = lib.literalExpression "^https?://$${config.services.strichliste.domain}(:[0-9]+)?$";

            description = ''
              Regular expression defining the allowed CORS origins.
            '';

            type = types.str;
          };

          DATABASE_URL = mkOption {
            default = "sqlite:////var/lib/strichliste/db.sqlite";

            description = ''
              See <https://www.doctrine-project.org/projects/doctrine-dbal/en/3.9/reference/configuration.html#connecting-using-a-url>
              for more URL examples.
            '';

            example = "postgresql://strichliste@localhost/strichliste?host=/run/postgresql";
            type = types.str;
          };
        };

        freeformType = types.attrs;
      };
    };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        Environment files to configure Symfony.

        See <https://github.com/strichliste/strichliste-backend/blob/v${cfg.packages.backend.version}/.env.dist> for possible options.

        ::: {.important}
        You should configure `APP_SECRET` here.
        :::
      '';

      example = lib.literalExpression ''
        [
          "/run/keys/strichliste.env"
        ]
      '';

      type = types.listOf types.path;
    };

    nginx = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to enable and configure an nginx vhost to serve strichliste.
        '';

        type = types.bool;
      };

      virtualHost = mkOption {
        description = ''
          Nginx virtual settings to allow direct customization of its settings.
        '';

        example = lib.literalExpression ''
          {
            enableACME = true;
            forceSSL = true;
          }
        '';

        type = types.submodule (
          import ../web-servers/nginx/vhost-options.nix {
            inherit config lib;
          }
        );
      };
    };

    packages = {
      backend = mkPackageOption pkgs "strichliste" { };

      frontend = mkOption {
        default = pkgs.strichliste.frontend;

        description = ''
          The strichliste-frontend package to use.
        '';

        type = types.package;
      };
    };

    settings = mkOption {
      description = ''
        The {file}`strichliste.yaml` configuration as a Nix attribute set.

        See the [configuration reference](https://github.com/strichliste/strichliste-backend/blob/v${cfg.packages.backend.version}/docs/Config.md)
        for possible options.
      '';

      type = types.submodule {
        options = {
          account = {
            boundary = {
              lower = mkOption {
                default = -200000;

                description = ''
                  The credit limit for user accounts.
                '';

                example = 0;
                type = types.int;
              };

              upper = mkOption {
                default = 200000;

                description = ''
                  The maximum balance on a user account.
                '';

                type = types.ints.positive;
              };
            };
          };

          common = {
            idleTimeout = mkOption {
              default = 30000;

              description = ''
                Time until the app returns to the start page.
              '';

              type = types.int;
            };
          };

          i18n = {
            currency = {
              alpha3 = mkOption {
                description = ''
                  [ISO 4217] alpha code representing the currency.

                  [ISO 4217]: https://en.wikipedia.org/wiki/ISO_4217#List_of_ISO_4217_currency_codes
                '';

                example = "EUR";
                type = types.str;
              };

              name = mkOption {
                description = ''
                  Name of the currency.
                '';

                example = "Euro";
                type = types.str;
              };

              symbol = mkOption {
                description = ''
                  Symbol for the currency.
                '';

                example = "€";
                type = types.str;
              };
            };

            language = mkOption {
              default = "en";

              description = ''
                Language used throughout the app.
              '';

              example = "de";
              type = types.str;
            };

            timezone = mkOption {
              default = config.time.timeZone;
              defaultText = lib.literalExpression "config.time.timeZone";

              description = ''
                Timezone used throughout the app, e.g. in the transaction log.
              '';

              example = "Europe/Berlin";
              type = types.str;
            };
          };

          payment = {
            boundary = {
              lower = mkOption {
                default = -2000;

                description = ''
                  The lowest amount that can be used for payments.
                '';

                example = 0;
                type = types.int;
              };

              upper = mkOption {
                default = 15000;

                description = ''
                  The highest amount that can be used for payment.
                '';

                type = types.ints.positive;
              };
            };

            deposit = {
              custom = mkOption {
                default = true;

                description = ''
                  Whether to allow custom amounts for deposits.
                '';

                type = types.bool;
              };

              enabled = mkOption {
                default = true;

                description = ''
                  Whether to allow money deposits.
                '';

                type = types.bool;
              };

              steps = mkOption {
                description = ''
                  List of selectable deposit amounts.

                  This should match your most common coins and banknotes.
                '';

                example = [
                  0.5
                  1
                  2
                  5
                  10
                  20
                ];

                type = types.listOf (
                  types.oneOf [
                    types.int
                    types.float
                  ]
                );
              };
            };

            dispense = {
              custom = mkOption {
                default = true;

                description = ''
                  Whether to allow custom spending amounts.
                '';

                type = types.bool;
              };

              enabled = mkOption {
                default = true;

                description = ''
                  Whether to allow spending money.
                '';

                type = types.bool;
              };

              steps = mkOption {
                description = ''
                  List of selectable spending amounts.

                  This should match your most common products.
                '';

                example = [
                  0.5
                  1
                  2
                  5
                  10
                  20
                ];

                type = types.listOf (
                  types.oneOf [
                    types.int
                    types.float
                  ]
                );
              };
            };

            splitInvoice = {
              enabled = mkOption {
                default = true;

                description = ''
                  Whether to allow splitting invoices.
                '';

                type = types.bool;
              };
            };

            transactions = {
              enabled = mkOption {
                default = true;

                description = ''
                  Whether to allow transactions between user accounts.
                '';

                type = types.bool;
              };
            };

            undo = {
              delete = mkOption {
                default = true;

                description = ''
                  Whether to allow deleting within the {option}`services.strichliste.settings.payment.undo.timeout` period.
                '';

                type = types.bool;
              };

              enabled = mkOption {
                default = true;

                description = ''
                  Whether to allow undoing transactions withing the {option}`services.strichliste.settings.payment.undo.timeout` period.
                '';

                type = types.bool;
              };

              timeout = mkOption {
                default = "5 minute";

                description = ''
                  The time period after creating a transaction in which undoing/deleting remains possible.

                  The format used is documented in <https://www.php.net/manual/en/dateinterval.createfromdatestring.php>.
                '';

                type = types.str;
              };
            };
          };

          user = {
            stalePeriod = mkOption {
              default = "10 day";

              description = ''
                Duration after which users are listed as inactive.

                The format used is documented in <https://www.php.net/manual/en/dateinterval.createfromdatestring.php>.

                ::: {.tip}
                This helps unclutter the user listing by prioritizing active users.
                :::
              '';

              example = "1 week";
              type = types.str;
            };
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.nginx.enable) {
      services.nginx.enable = true;

      services.nginx.virtualHosts.${cfg.domain} = mkMerge [
        cfg.nginx.virtualHost
        {
          locations = {
            "/" = {
              tryFiles = toString [
                "$uri"
                "$uri/"
                "index.html"
              ];
            };

            "/api/" = {
              extraConfig = ''
                fastcgi_intercept_errors on;
                fastcgi_pass unix:${config.services.phpfpm.pools.strichliste.socket};
                fastcgi_request_buffering off;
              '';

              fastcgiParams = {
                REQUEST_URI = "$request_uri";
                SCRIPT_FILENAME = "${cfg.packages.backend}/share/php/strichliste-backend/public/index.php";
                SCRIPT_NAME = "/index.php";
                front_controller_active = "true";
                modHeadersAvailable = "true";
              };
            };
          };

          root = mkForce "${cfg.packages.frontend}";
        }
      ];

      services.phpfpm.pools.strichliste.settings = {
        "listen.group" = config.services.nginx.group;
        "listen.owner" = config.services.nginx.user;
      };
    })

    (mkIf cfg.enable {
      environment.etc."strichliste.yaml".source = settingsFile;

      services.phpfpm.pools.strichliste = {
        inherit (cfg.packages.backend) phpPackage;
        group = "strichliste";

        settings = {
          # support environment variables
          "clear_env" = false;
          "pm" = "dynamic";
          "pm.max_children" = 8;
          "pm.max_requests" = 256;
          "pm.max_spare_servers" = 4;
          "pm.min_spare_servers" = 1;
          "pm.start_servers" = 1;
        };

        user = "strichliste";
      };

      systemd.services.phpfpm-strichliste = {
        inherit (cfg) environment;

        preStart = toString [
          (lib.getExe cfg.packages.backend)
          "cache:clear"
        ];

        restartTriggers = [ settingsFile ];
        serviceConfig.EnvironmentFile = cfg.environmentFiles;
      };

      systemd.services.strichliste-migrate = {
        inherit (cfg) environment;
        after = unitDependencies;
        before = [ "phpfpm-strichliste.service" ];

        serviceConfig = {
          EnvironmentFile = cfg.environmentFiles;

          ExecStart = toString [
            (lib.getExe cfg.packages.backend)
            "doctrine:migrations:migrate"
            "--allow-no-migration"
            "--no-interaction"
          ];

          Group = "strichliste";
          RemainAfterExit = true;
          Type = "oneshot";
          User = "strichliste";
        };

        wantedBy = [ "phpfpm-strichliste.service" ];
        wants = unitDependencies;
      };

      systemd.tmpfiles.settings."strichliste" = {
        ${cfg.environment.APP_CACHE_DIR}.d = {
          group = "strichliste";
          mode = "0700";
          user = "strichliste";
        };

        ${cfg.environment.APP_LOG_DIR}.d = {
          group = "strichliste";
          mode = "0700";
          user = "strichliste";
        };
      };

      users.groups.strichliste = { };

      users.users.strichliste = {
        createHome = true;
        group = "strichliste";
        home = "/var/lib/strichliste";
        isSystemUser = true;
      };
    })
  ];

  meta.buildDocsInSandbox = false;
}

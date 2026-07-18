{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
with lib;
let
  cfg = config.services.lemmy;
  settingsFormat = pkgs.formats.json { };
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "lemmy"
      "jwtSecretPath"
    ] "As of v0.13.0, Lemmy auto-generates the JWT secret.")
  ];

  options.services.lemmy = {

    enable = mkEnableOption "lemmy a federated alternative to reddit in rust";

    adminPasswordFile = mkOption {
      default = null;
      description = "File which contains the value of `setup.admin_password`.";
      type = with types; nullOr path;
    };

    caddy.enable = mkEnableOption "exposing lemmy with the caddy reverse proxy";

    database = {
      createLocally = mkEnableOption "creation of database on the instance";

      uri = mkOption {
        default = null;
        description = "The connection URI to use. Takes priority over the configuration file if set.";
        type = with types; nullOr str;
      };

      uriFile = mkOption {
        default = null;
        description = "File which contains the database uri.";
        type = with types; nullOr path;
      };
    };

    nginx.enable = mkEnableOption "exposing lemmy with the nginx reverse proxy";

    pictrsApiKeyFile = mkOption {
      default = null;
      description = "File which contains the value of `pictrs.api_key`.";
      type = with types; nullOr path;
    };

    server = {
      package = mkPackageOption pkgs "lemmy-server" { };
    };

    settings = mkOption {
      default = { };
      description = "Lemmy configuration";

      type = types.submodule {
        options.captcha = {
          difficulty = mkOption {
            default = "medium";
            description = "The difficultly of the captcha to solve.";

            type = types.enum [
              "easy"
              "medium"
              "hard"
            ];
          };

          enabled = mkOption {
            default = true;
            description = "Enable Captcha.";
            type = types.bool;
          };
        };

        options.hostname = mkOption {
          default = null;
          description = "The domain name of your instance (eg 'lemmy.ml').";
          type = types.str;
        };

        options.port = mkOption {
          default = 8536;
          description = "Port where lemmy should listen for incoming requests.";
          type = types.port;
        };

        freeformType = settingsFormat.type;
      };
    };

    smtpPasswordFile = mkOption {
      default = null;
      description = "File which contains the value of `email.smtp_password`.";
      type = with types; nullOr path;
    };

    ui = {
      package = mkPackageOption pkgs "lemmy-ui" { };

      port = mkOption {
        default = 1234;
        description = "Port where lemmy-ui should listen for incoming requests.";
        type = types.port;
      };
    };
  };

  config =
    let
      secretOptions = {
        adminPasswordFile = {
          path = cfg.adminPasswordFile;

          setting = [
            "setup"
            "admin_password"
          ];
        };

        pictrsApiKeyFile = {
          path = cfg.pictrsApiKeyFile;

          setting = [
            "pictrs"
            "api_key"
          ];
        };

        smtpPasswordFile = {
          path = cfg.smtpPasswordFile;

          setting = [
            "email"
            "smtp_password"
          ];
        };

        uriFile = {
          path = cfg.database.uriFile;

          setting = [
            "database"
            "uri"
          ];
        };
      };
      secrets = lib.filterAttrs (option: data: data.path != null) secretOptions;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            cfg.database.createLocally
            -> cfg.settings.database.host == "localhost" || cfg.settings.database.host == "/run/postgresql";

          message = "if you want to create the database locally, you need to use a local database";
        }
        {
          assertion =
            (!(hasAttrByPath [ "federation" ] cfg.settings))
            && (!(hasAttrByPath [ "federation" "enabled" ] cfg.settings));

          message = "`services.lemmy.settings.federation` was removed in 0.17.0 and no longer has any effect";
        }
        {
          assertion = cfg.database.uriFile != null -> cfg.database.uri == null && !cfg.database.createLocally;
          message = "specifying a database uri while also specifying a database uri file is not allowed";
        }
      ];

      services.caddy = mkIf cfg.caddy.enable {
        enable = mkDefault true;

        virtualHosts."${cfg.settings.hostname}" = {
          extraConfig = ''
            handle_path /static/* {
              root * ${cfg.ui.package}/dist
              file_server
            }
            handle_path /static/${cfg.ui.package.version}/* {
              root * ${cfg.ui.package}/dist
              file_server
            }
            @for_backend {
              path /api/* /pictrs/* /feeds/* /nodeinfo/*
            }
            handle @for_backend {
              reverse_proxy 127.0.0.1:${toString cfg.settings.port}
            }
            @post {
              method POST
            }
            handle @post {
              reverse_proxy 127.0.0.1:${toString cfg.settings.port}
            }
            @jsonld {
              header Accept "application/activity+json"
              header Accept "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\""
            }
            handle @jsonld {
              reverse_proxy 127.0.0.1:${toString cfg.settings.port}
            }
            handle {
              reverse_proxy 127.0.0.1:${toString cfg.ui.port}
            }
          '';
        };
      };

      services.lemmy.settings =
        lib.attrsets.recursiveUpdate
          (
            mapAttrs (name: mkDefault) {
              actor_name_max_length = 20;
              bind = "127.0.0.1";

              pictrs = {
                url = with config.services.pict-rs; "http://${address}:${toString port}";
              };

              rate_limit.image = 6;
              rate_limit.image_per_second = 3600;
              rate_limit.message = 180;
              rate_limit.message_per_second = 60;
              rate_limit.post = 6;
              rate_limit.post_per_second = 600;
              rate_limit.register = 3;
              rate_limit.register_per_second = 3600;
              tls_enabled = true;
            }
            // {
              database = mapAttrs (name: mkDefault) {
                database = "lemmy";
                host = "/run/postgresql";
                pool_size = 5;
                port = 5432;
                user = "lemmy";
              };
            }
          )
          (
            lib.foldlAttrs (
              acc: option: data:
              acc // lib.setAttrByPath data.setting { _secret = option; }
            ) { } secrets
          );

      services.nginx = mkIf cfg.nginx.enable {
        enable = mkDefault true;

        virtualHosts."${cfg.settings.hostname}".locations =
          let
            ui = "http://127.0.0.1:${toString cfg.ui.port}";
            backend = "http://127.0.0.1:${toString cfg.settings.port}";
          in
          {
            "/" = {
              # mixed frontend and backend requests, based on the request headers
              extraConfig = ''
                set $proxpass "${ui}";
                if ($http_accept = "application/activity+json") {
                  set $proxpass "${backend}";
                }
                if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
                  set $proxpass "${backend}";
                }
                if ($request_method = POST) {
                  set $proxpass "${backend}";
                }

                # Cuts off the trailing slash on URLs to make them valid
                rewrite ^(.+)/+$ $1 permanent;

                proxy_pass $proxpass;
                # Proxied `Host` header is required to validate ActivityPub HTTP signatures for incoming events.
                # The other headers are optional, for the sake of better log data.
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              '';
            };

            "~ ^/(api|pictrs|feeds|nodeinfo|.well-known)" = {
              # backend requests
              proxyPass = backend;
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };
          };
      };

      services.pict-rs.enable = true;

      # the option name is the id of the credential loaded by LoadCredential
      services.postgresql = mkIf cfg.database.createLocally {
        enable = true;
        ensureDatabases = [ cfg.settings.database.database ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = cfg.settings.database.user;
          }
        ];
      };

      systemd.services.lemmy =
        let
          substitutedConfig = "/run/lemmy/config.hjson";
        in
        {
          after = [ "pict-rs.service" ] ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];
          description = "Lemmy server";

          documentation = [
            "https://join-lemmy.org/docs/en/admins/from_scratch.html"
            "https://join-lemmy.org/docs/en/"
          ];

          environment = {
            LEMMY_CONFIG_LOCATION =
              if secrets == { } then settingsFormat.generate "config.hjson" cfg.settings else substitutedConfig;

            LEMMY_DATABASE_URL =
              if cfg.database.uri != null then
                cfg.database.uri
              else
                (mkIf (cfg.database.createLocally) "postgres:///lemmy?host=/run/postgresql&user=lemmy");
          };

          # substitute secrets and prevent others from reading the result
          # if somehow $CREDENTIALS_DIRECTORY is not set we fail
          preStart = mkIf (secrets != { }) ''
            set -u
            umask u=rw,g=,o=
            cd "$CREDENTIALS_DIRECTORY"
            ${utils.genJqSecretsReplacementSnippet cfg.settings substitutedConfig}
          '';

          requires = lib.optionals cfg.database.createLocally [ "postgresql.target" ];

          serviceConfig = {
            DynamicUser = true;
            ExecStart = "${cfg.server.package}/bin/lemmy_server";

            LoadCredential = lib.foldlAttrs (
              acc: option: data:
              acc ++ [ "${option}:${toString data.path}" ]
            ) [ ] secrets;

            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            RuntimeDirectory = "lemmy";
          };

          wantedBy = [ "multi-user.target" ];
        };

      systemd.services.lemmy-ui = {
        after = [ "lemmy.service" ];
        description = "Lemmy ui";

        documentation = [
          "https://join-lemmy.org/docs/en/admins/from_scratch.html"
          "https://join-lemmy.org/docs/en/"
        ];

        environment = {
          LEMMY_UI_HOST = "127.0.0.1:${toString cfg.ui.port}";
          LEMMY_UI_HTTPS = "false";
          LEMMY_UI_LEMMY_EXTERNAL_HOST = cfg.settings.hostname;
          LEMMY_UI_LEMMY_INTERNAL_HOST = "127.0.0.1:${toString cfg.settings.port}";
          NODE_ENV = "production";
        };

        requires = [ "lemmy.service" ];

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${pkgs.lib.getExe pkgs.nodejs-slim} ${cfg.ui.package}/dist/js/server.js";
          WorkingDirectory = "${cfg.ui.package}";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.doc = ./lemmy.md;
  meta.maintainers = with maintainers; [ happysalada ];

}

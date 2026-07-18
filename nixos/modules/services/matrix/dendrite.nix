{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dendrite;
  settingsFormat = pkgs.formats.yaml { };
  configurationYaml = settingsFormat.generate "dendrite.yaml" cfg.settings;
  workingDir = "/var/lib/dendrite";
in
{
  options.services.dendrite = {
    enable = lib.mkEnableOption "matrix.org dendrite";
    package = lib.mkPackageOption pkgs "dendrite" { };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.
        Secrets may be passed to the service without adding them to the world-readable
        Nix store, by specifying placeholder variables as the option value in Nix and
        setting these variables accordingly in the environment file. Currently only used
        for the registration secret to allow secure registration when
        client_api.registration_disabled is true.

        ```
          # snippet of dendrite-related config
          services.dendrite.settings.client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
        ```

        ```
          # content of the environment file
          REGISTRATION_SHARED_SECRET=verysecretpassword
        ```

        Note that this file needs to be available on the host on which
        `dendrite` is running.
      '';

      example = "/var/lib/dendrite/registration_secret";
      type = lib.types.nullOr lib.types.path;
    };

    httpPort = lib.mkOption {
      default = 8008;

      description = ''
        The port to listen for HTTP requests on.
      '';

      type = lib.types.nullOr lib.types.port;
    };

    httpsPort = lib.mkOption {
      default = null;

      description = ''
        The port to listen for HTTPS requests on.
      '';

      type = lib.types.nullOr lib.types.port;
    };

    loadCredential = lib.mkOption {
      default = [ ];

      description = ''
        This can be used to pass secrets to the systemd service without adding them to
        the nix store.
        To use the example setting, see the example of
        {option}`services.dendrite.settings.global.private_key`.
        See the LoadCredential section of systemd.exec manual for more information.
      '';

      example = [ "private_key:/path/to/my_private_key" ];
      type = lib.types.listOf lib.types.str;
    };

    openRegistration = lib.mkOption {
      default = false;

      description = ''
        Allow open registration without secondary verification (reCAPTCHA).
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for dendrite, see:
        <https://github.com/matrix-org/dendrite/blob/main/dendrite-sample.yaml>
        for available options with which to populate settings.
      '';

      type = lib.types.submodule {
        options.app_service_api.database = {
          connection_string = lib.mkOption {
            default = "file:federationapi.db";

            description = ''
              Database for the Appservice API.
            '';

            type = lib.types.str;
          };
        };

        options.client_api = {
          registration_disabled = lib.mkOption {
            default = true;

            description = ''
              Whether to disable user registration to the server
              without the shared secret.
            '';

            type = lib.types.bool;
          };
        };

        options.federation_api.database = {
          connection_string = lib.mkOption {
            default = "file:federationapi.db";

            description = ''
              Database for the Federation API.
            '';

            type = lib.types.str;
          };
        };

        options.global = {
          private_key = lib.mkOption {
            description = ''
              The path to the signing private key file, used to sign
              requests and events.

              ```
                nix-shell -p dendrite --command "generate-keys --private-key matrix_key.pem"
              ```
            '';

            example = "$CREDENTIALS_DIRECTORY/private_key";
            type = lib.types.either lib.types.path (lib.types.strMatching "^\\$CREDENTIALS_DIRECTORY/.+");
          };

          server_name = lib.mkOption {
            description = ''
              The domain name of the server, with optional explicit port.
              This is used by remote servers to connect to this server.
              This is also the last part of your UserID.
            '';

            example = "example.com";
            type = lib.types.str;
          };

          trusted_third_party_id_servers = lib.mkOption {
            default = [
              "matrix.org"
              "vector.im"
            ];

            description = ''
              Lists of domains that the server will trust as identity
              servers to verify third party identifiers such as phone
              numbers and email addresses
            '';

            example = [ "matrix.org" ];
            type = lib.types.listOf lib.types.str;
          };
        };

        options.key_server.database = {
          connection_string = lib.mkOption {
            default = "file:keyserver.db";

            description = ''
              Database for the Key Server (for end-to-end encryption).
            '';

            type = lib.types.str;
          };
        };

        options.media_api = {
          base_path = lib.mkOption {
            default = "${workingDir}/media_store";

            description = ''
              Storage path for uploaded media.
            '';

            type = lib.types.str;
          };

          database = {
            connection_string = lib.mkOption {
              default = "file:mediaapi.db";

              description = ''
                Database for the Media API.
              '';

              type = lib.types.str;
            };
          };
        };

        options.mscs = {
          database = {
            connection_string = lib.mkOption {
              default = "file:mscs.db";

              description = ''
                Database for exerimental MSC's.
              '';

              type = lib.types.str;
            };
          };
        };

        options.relay_api.database = {
          connection_string = lib.mkOption {
            default = "file:relayapi.db";

            description = ''
              Database for the Relay Server.
            '';

            type = lib.types.str;
          };
        };

        options.room_server.database = {
          connection_string = lib.mkOption {
            default = "file:roomserver.db";

            description = ''
              Database for the Room Server.
            '';

            type = lib.types.str;
          };
        };

        options.sync_api.database = {
          connection_string = lib.mkOption {
            default = "file:syncserver.db";

            description = ''
              Database for the Sync API.
            '';

            type = lib.types.str;
          };
        };

        options.sync_api.search = {
          enabled = lib.mkEnableOption "Dendrite's full-text search engine";

          index_path = lib.mkOption {
            default = "${workingDir}/searchindex";

            description = ''
              The path the search index will be created in.
            '';

            type = lib.types.str;
          };

          language = lib.mkOption {
            default = "en";

            description = ''
              The language most likely to be used on the server - used when indexing, to
              ensure the returned results match expectations. A full list of possible languages
              can be found at <https://github.com/blevesearch/bleve/tree/master/analysis/lang>
            '';

            type = lib.types.str;
          };
        };

        options.user_api = {
          account_database = {
            connection_string = lib.mkOption {
              default = "file:userapi_accounts.db";

              description = ''
                Database for the User API, accounts.
              '';

              type = lib.types.str;
            };
          };

          device_database = {
            connection_string = lib.mkOption {
              default = "file:userapi_devices.db";

              description = ''
                Database for the User API, devices.
              '';

              type = lib.types.str;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    tlsCert = lib.mkOption {
      default = null;

      description = ''
        The path to the TLS certificate.

        ```
          nix-shell -p dendrite --command "generate-keys --tls-cert server.crt --tls-key server.key"
        ```
      '';

      example = "/var/lib/dendrite/server.cert";
      type = lib.types.nullOr lib.types.path;
    };

    tlsKey = lib.mkOption {
      default = null;

      description = ''
        The path to the TLS key.

        ```
          nix-shell -p dendrite --command "generate-keys --tls-cert server.crt --tls-key server.key"
        ```
      '';

      example = "/var/lib/dendrite/server.key";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.httpsPort != null -> (cfg.tlsCert != null && cfg.tlsKey != null);

        message = ''
          If Dendrite is configured to use https, tlsCert and tlsKey must be provided.

          nix-shell -p dendrite --command "generate-keys --tls-cert server.crt --tls-key server.key"
        '';
      }
      {
        assertion = !(cfg.settings.sync_api.search ? enable);

        message = ''
          The `services.dendrite.settings.sync_api.search.enable` option
          has been renamed to `services.dendrite.settings.sync_api.search.enabled`.
        '';
      }
    ];

    systemd.services.dendrite = {
      after = [
        "network.target"
      ];

      description = "Dendrite Matrix homeserver";

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart = lib.strings.concatStringsSep " " (
          [
            (lib.getExe cfg.package)
            "--config /run/dendrite/dendrite.yaml"
          ]
          ++ lib.optionals (cfg.httpPort != null) [
            "--http-bind-address :${toString cfg.httpPort}"
          ]
          ++ lib.optionals (cfg.httpsPort != null) [
            "--https-bind-address :${toString cfg.httpsPort}"
            "--tls-cert ${cfg.tlsCert}"
            "--tls-key ${cfg.tlsKey}"
          ]
          ++ lib.optionals cfg.openRegistration [
            "--really-enable-open-registration"
          ]
        );

        ExecStartPre = [
          ''
            ${pkgs.envsubst}/bin/envsubst \
              -i ${configurationYaml} \
              -o /run/dendrite/dendrite.yaml
          ''
        ];

        LimitNOFILE = 65535;
        LoadCredential = cfg.loadCredential;
        Restart = "on-failure";
        RuntimeDirectory = "dendrite";
        RuntimeDirectoryMode = "0700";
        StateDirectory = "dendrite";
        Type = "simple";
        WorkingDirectory = workingDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

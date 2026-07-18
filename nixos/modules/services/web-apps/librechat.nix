{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.librechat;
  meiliCfg = config.services.meilisearch;
  format = pkgs.formats.yaml { };
  configFile = format.generate "librechat.yaml" cfg.settings;
  exportCredentials = n: _: ''export ${n}="$(${pkgs.systemd}/bin/systemd-creds cat ${n}_FILE)"'';
  exportAllCredentials = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList exportCredentials vars);
  getLoadCredentialList = lib.mapAttrsToList (n: v: "${n}_FILE:${v}") cfg.credentials;
in
{
  options.services.librechat = {
    enable = lib.mkEnableOption "the LibreChat server";
    package = lib.mkPackageOption pkgs "librechat" { };

    credentials = lib.mkOption {
      default = { };

      description = ''
        Environment variables which are loaded from the contents of files at a file paths, mainly used for secrets.
        See [LibreChat environment variables](https://www.librechat.ai/docs/configuration/dotenv).
        Alternatively you can use `services.librechat.credentialsFile` to define all the variables in a single file.
      '';

      example = {
        CREDS_KEY = "/run/secrets/creds_key";
      };

      type = lib.types.attrsOf lib.types.path;
    };

    credentialsFile = lib.mkOption {
      default = "/dev/null";

      description = ''
        Path to a file that contains environment variables.
        See [LibreChat environment variables](https://www.librechat.ai/docs/configuration/dotenv).

        Example content of the file:
        ```
        CREDS_KEY=6d6deb03cdfb27ea454f6b9ddd42494bdce4af25d50d8aee454ddce583690cc5
        ```

        Alternatively you can use `services.librechat.credentials` to define the value of each variable in a separate file.
      '';

      example = "/run/secrets/librechat";
      type = lib.types.nullOr lib.types.path;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/librechat";
      description = "Absolute path for where the LibreChat server will use as its data directory to store logs, user uploads, and generated images.";
      example = "/persist/librechat";
      type = lib.types.path;
    };

    enableLocalDB = lib.mkEnableOption "a local mongodb instance";

    env = lib.mkOption {
      description = ''
        Environment variables that will be set for the service.
        See [LibreChat environment variables](https://www.librechat.ai/docs/configuration/dotenv).
      '';

      example = {
        ALLOW_REGISTRATION = true;
        CONSOLE_JSON_STRING_LENGTH = 255;
        HOST = "0.0.0.0";
        PORT = 2309;
      };

      type = lib.types.submodule {
        options = {
          CONFIG_PATH = lib.mkOption {
            default = configFile;
            internal = true;
            readOnly = true;
          };

          LIBRECHAT_LOG_DIR = lib.mkOption {
            default = "${cfg.dataDir}/logs";
            defaultText = lib.literalExpression "/var/lib/librechat/logs";

            description = ''
              Logs will be saved into this directory.
              By default it is relative to `services.librechat.dataDir`.
            '';

            type = lib.types.str;
          };

          PORT = lib.mkOption {
            default = 3080;
            description = "The value that will be passed to the PORT environment variable, telling LibreChat what to listen on.";
            example = 2309;
            type = with lib.types; coercedTo port toString str;
          };
        };

        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            path
            (coercedTo int toString str)
            (coercedTo float toString str)
            (coercedTo port toString str)
            (coercedTo bool (x: if x then "true" else "false") str)
          ]);
      };
    };

    group = lib.mkOption {
      default = "librechat";
      description = "The group to run the service as.";
      example = "users";
      type = lib.types.str;
    };

    meilisearch = lib.mkOption {
      default = { };

      description = ''
        See [LibreChat search feature](https://www.librechat.ai/docs/features/search).
      '';

      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            default = false;

            description = ''
              Whether to enable and configure Meilisearch locally for Librechat.
              You will manually need to set `services.meilisearch.masterKeyFile`.
            '';

            example = true;
            type = lib.types.bool;
          };
        };
      };
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the port in the firewall.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = {
        version = "1.2.1";
      };

      description = ''
        A free-form attribute set that will be written to librechat.yaml.
        See the [LibreChat configuration options](https://www.librechat.ai/docs/configuration/librechat_yaml).
        You can use environment variables by wrapping them in $\{}. Take care to escape the \$ character.
      '';

      example = {
        cache = true;

        endpoints = {
          custom = [
            {
              apiKey = "\${OPENROUTER_KEY}";
              baseURL = "https://openrouter.ai/api/v1";
              dropParams = [ "stop" ];
              modelDisplayLabel = "OpenRouter";

              models = {
                default = [ "meta-llama/llama-3-70b-instruct" ];
                fetch = true;
              };

              name = "OpenRouter";
              titleConvo = true;
              titleModule = "meta-llama/llama-3-70b-instruct";
            }
          ];
        };

        interface = {
          privacyPolicy = {
            externalUrl = "https://librechat.ai/privacy-policy";
            openNewTab = true;
          };
        };

        version = "1.2.1";
      };

      type = lib.types.submodule {
        freeformType = format.type;
      };
    };

    user = lib.mkOption {
      default = "librechat";
      description = "The user to run the service as.";
      example = "alice";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.env ? MONGO_URI || cfg.credentials ? MONGO_URI;
        message = "MongoDB is not configured, either set `services.librechat.enableLocalDB = true` or provide your own MongoDB instance by setting `services.librechat.env.MONGO_URI` or `services.credentials.MONGO_URI`.";
      }
      {
        assertion =
          cfg.credentialsFile != "/dev/null"
          || (
            (cfg.env ? CREDS_KEY || cfg.credentials ? CREDS_KEY)
            && (cfg.env ? CREDS_IV || cfg.credentials ? CREDS_IV)
            && (cfg.env ? JWT_SECRET || cfg.credentials ? JWT_SECRET)
            && (cfg.env ? JWT_REFRESH_SECRET || cfg.credentials ? JWT_REFRESH_SECRET)
          );

        message = ''
          CREDS_KEY, CREDS_IV, JWT_SECRET, and JWT_REFRESH_SECRET must be defined in `services.librechat.credentials` and point to locations of files on the host or in a file that `services.credentialsFile` is pointing to.
          Alternatively it can be defined in `services.librechat.env` with literal values but they will be saved within the world-readable nix store.;
          You can use https://www.librechat.ai/toolkit/creds_generator to generate these.
        '';
      }
      {
        assertion = cfg.meilisearch.enable -> meiliCfg.masterKeyFile != null;

        message = ''
          LibreChat's Meilisearch integration requires `services.meilisearch.masterKeyFile` to be set.
        '';
      }
    ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
    services.librechat.credentials.MEILI_MASTER_KEY = lib.mkIf cfg.meilisearch.enable meiliCfg.masterKeyFile;
    services.librechat.env.MEILI_HOST = lib.mkIf cfg.meilisearch.enable "http://${meiliCfg.settings.http_addr}";
    services.librechat.env.MONGO_URI = lib.mkIf cfg.enableLocalDB "mongodb://localhost:27017";
    services.librechat.env.SEARCH = lib.mkIf cfg.meilisearch.enable true;
    services.meilisearch.enable = lib.mkIf cfg.meilisearch.enable true;
    services.mongodb.enable = lib.mkIf cfg.enableLocalDB true;

    systemd.services.librechat = {
      after = [
        "tmpfiles.target"
      ]
      ++ lib.optional cfg.meilisearch.enable "meilisearch.service";

      description = "Open-source app for all your AI conversations, fully customizable and compatible with any AI provider";
      environment = cfg.env;

      script = # sh
        ''
          ${exportAllCredentials cfg.credentials}
          cd ${cfg.dataDir}
          ${lib.getExe cfg.package}
        '';

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        EnvironmentFile = cfg.credentialsFile;
        Group = cfg.group;
        LoadCredential = getLoadCredentialList;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = baseNameOf cfg.dataDir;
        Type = "simple";
        UMask = "0077";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = lib.optional cfg.meilisearch.enable "meilisearch.service";
    };

    systemd.tmpfiles.settings."10-librechat"."${cfg.dataDir}".d = {
      inherit (cfg) user group;
      mode = "0755";
    };

    users.groups.librechat = lib.mkIf (cfg.user == "librechat") { };

    users.users.librechat = lib.mkIf (cfg.user == "librechat") {
      description = "LibreChat server user";
      group = "librechat";
      isSystemUser = true;
      name = "librechat";
    };
  };

  meta.maintainers = with lib.maintainers; [
    gepbird
    niklaskorz
    rrvsh
  ];
}

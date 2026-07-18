{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sharkey;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yml" cfg.settings;
in
{
  options.services.sharkey =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        mkPackageOption
        types
        ;
    in
    {
      enable = mkEnableOption "Sharkey, a Sharkish microblogging platform";
      package = mkPackageOption pkgs "sharkey" { };

      environmentFiles = mkOption {
        default = [ ];

        description = ''
          List of paths to files containing environment variables for Sharkey to use at runtime.

          This is useful for keeping secrets out of the Nix store. See
          <https://docs.joinsharkey.org/docs/install/configuration/> for how to configure Sharkey using environment
          variables.
        '';

        example = [ "/run/secrets/sharkey-env" ];
        type = types.listOf types.path;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open ports in the NixOS firewall for Sharkey.
        '';

        example = true;
        type = types.bool;
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration options for Sharkey.

          See <https://activitypub.software/TransFem-org/Sharkey/-/blob/develop/.config/example.yml> for a list of all
          available configuration options.
        '';

        type = types.submodule {
          options = {
            address = mkOption {
              default = "0.0.0.0";

              description = ''
                The address that Sharkey binds to.
              '';

              example = "127.0.0.1";
              type = types.str;
            };

            fulltextSearch.provider = mkOption {
              default = "sqlLike";

              description = ''
                Which provider to use for full text search.

                All options other than `sqlLike` require extra setup - see the comments in
                <https://activitypub.software/TransFem-org/Sharkey/-/blob/develop/.config/example.yml> for details.

                If `sqlPgroonga` is set, and `services.sharkey.setupPostgres` is `true`, the pgroonga extension will
                automatically be setup. You still need to create an index manually.

                If using Meilisearch, consider setting `services.sharkey.setupMeilisearch` instead, which will
                configure Meilisearch for you.
              '';

              example = "sqlPgroonga";

              type = types.enum [
                "sqlLike"
                "sqlPgroonga"
                "sqlTsvector"
                "meilisearch"
              ];
            };

            id = mkOption {
              default = "aidx";

              description = ''
                The ID generation method for Sharkey to use.

                Do NOT change this after initial setup!
              '';

              type = types.enum [
                "aid"
                "aidx"
                "meid"
                "ulid"
                "objectid"
              ];
            };

            mediaDirectory = mkOption {
              default = "/var/lib/sharkey";

              description = ''
                Path to the folder where Sharkey stores uploaded media such as images and attachments.
              '';

              type = types.path;
            };

            port = mkOption {
              default = 3000;

              description = ''
                The port that Sharkey will listen on.
              '';

              type = types.port;
            };

            socket = mkOption {
              default = null;

              description = ''
                If specified, creates a UNIX socket at the given path that Sharkey listens on.
              '';

              example = "/run/sharkey/sharkey.sock";
              type = types.nullOr types.path;
            };

            url = mkOption {
              description = ''
                The full URL that the Sharkey instance will be publically accessible on.

                Do NOT change this after initial setup!
              '';

              example = "https://blahaj.social/";
              type = types.str;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      setupMeilisearch = mkOption {
        default = false;

        description = ''
          Whether to automatically set up a local Meilisearch instance and configure Sharkey to use it.

          You need to ensure `services.meilisearch.masterKeyFile` is correctly configured for a working
          Meilisearch setup. You also need to configure Sharkey to use an API key obtained from Meilisearch with the
          `MK_CONFIG_MEILISEARCH_APIKEY` environment variable, and set `services.sharkey.settings.meilisearch.index` to
          the created index. See <https://docs.joinsharkey.org/docs/customisation/search/meilisearch/> for how to create
          an API key and index.
        '';

        example = true;
        type = types.bool;
      };

      setupPostgresql = mkOption {
        default = true;

        description = ''
          Whether to automatically set up a local PostgreSQL database and configure Sharkey to use it.
        '';

        example = false;
        type = types.bool;
      };

      setupRedis = mkOption {
        default = true;

        description = ''
          Whether to automatically set up a local Redis cache and configure Sharkey to use it.
        '';

        example = false;
        type = types.bool;
      };
    };

  config =
    let
      inherit (lib) mkDefault mkIf mkMerge;
    in
    mkIf cfg.enable (mkMerge [
      {
        environment.etc."sharkey/default.yml".source = configFile;

        systemd.services.sharkey = {
          description = "Sharkey";
          documentation = [ "https://docs.joinsharkey.org/" ];
          environment.MISSKEY_CONFIG_DIR = "/etc/sharkey";

          serviceConfig = {
            CapabilityBoundingSet = "";
            ConfigurationDirectory = "sharkey";
            DynamicUser = true;
            EnvironmentFile = cfg.environmentFiles;
            ExecStart = "${lib.getExe cfg.package} migrateandstart";
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            PrivateUsers = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            ReadWritePaths = [ cfg.settings.mediaDirectory ];
            Restart = "always";
            RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RuntimeDirectory = "sharkey";
            StateDirectory = "sharkey";
            SyslogIdentifier = "sharkey";
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "~@cpu-emulation @debug @mount @obsolete @privileged @resources"
              "@chown"
            ];

            TimeoutSec = 60;
            Type = "simple";
            UMask = "0077";
          };

          startLimitBurst = 5;
          startLimitIntervalSec = 60;
          wantedBy = [ "multi-user.target" ];
        };
      }
      (mkIf cfg.openFirewall {
        networking.firewall.allowedTCPPorts = [ cfg.settings.port ];
      })
      (mkIf cfg.setupMeilisearch {
        services.meilisearch = {
          enable = mkDefault true;
          settings.env = mkDefault "production";
        };

        services.sharkey.settings = {
          fulltextSearch.provider = "meilisearch";

          meilisearch = {
            host = config.services.meilisearch.listenAddress;
            port = config.services.meilisearch.listenPort;
          };
        };

        systemd.services.sharkey = {
          after = [ "meilisearch.service" ];
          wants = [ "meilisearch.service" ];
        };
      })
      (mkIf cfg.setupPostgresql {
        services.postgresql = {
          enable = mkDefault true;
          ensureDatabases = [ "sharkey" ];

          ensureUsers = [
            {
              ensureDBOwnership = true;
              name = "sharkey";
            }
          ];

          extensions = mkIf (cfg.settings.fulltextSearch.provider == "sqlPgroonga") (ps: [ ps.pgroonga ]);
        };

        services.sharkey.settings.db = {
          db = "sharkey";
          host = "/run/postgresql";
        };

        systemd.services.sharkey = {
          after = [ "postgresql.target" ];
          bindsTo = [ "postgresql.target" ];
        };
      })
      (mkIf cfg.setupRedis {
        services.redis.servers.sharkey.enable = mkDefault true;
        services.sharkey.settings.redis.path = config.services.redis.servers.sharkey.unixSocket;

        systemd.services.sharkey = {
          after = [ "redis-sharkey.service" ];
          bindsTo = [ "redis-sharkey.service" ];

          serviceConfig.SupplementaryGroups = [
            config.services.redis.servers.sharkey.group
          ];
        };
      })
    ]);

  meta.maintainers = with lib.maintainers; [
    tmarkus
  ];
}

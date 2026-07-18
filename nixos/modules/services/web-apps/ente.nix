{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    getExe
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    optional
    types
    ;

  cfgApi = config.services.ente.api;
  cfgWeb = config.services.ente.web;

  webPackage =
    enteApp:
    cfgWeb.package.override {
      inherit enteApp;
      enteMainUrl = "https://${cfgWeb.domains.photos}";

      extraBuildEnv = {
        NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT = "https://${cfgWeb.domains.albums}";
        NEXT_PUBLIC_ENTE_ENDPOINT = "https://${cfgWeb.domains.api}";
        NEXT_TELEMETRY_DISABLED = "1";
      };
    };

  defaultUser = "ente";
  defaultGroup = "ente";
  dataDir = "/var/lib/ente";

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.services.ente = {
    api = {
      enable = mkEnableOption "Museum (API server for ente.io)";
      package = mkPackageOption pkgs "museum" { };

      domain = mkOption {
        description = "The domain under which the api will be served.";
        example = "api.ente.example.com";
        type = types.str;
      };

      enableLocalDB = mkEnableOption "the automatic creation of a local postgres database for museum.";

      group = mkOption {
        default = defaultGroup;
        description = "Group under which museum runs. If you set this option you must make sure the group exists.";
        type = types.str;
      };

      nginx.enable = mkEnableOption "nginx proxy for the API server";

      settings = mkOption {
        default = { };

        description = ''
          Museum yaml configuration. Refer to upstream [local.yaml](https://github.com/ente-io/ente/blob/main/server/configurations/local.yaml) for more information.
          You can specify secret values in this configuration by setting `somevalue._secret = "/path/to/file"` instead of setting `somevalue` directly.
        '';

        type = types.submodule {
          options = {
            apps = {
              accounts = mkOption {
                default = "https://accounts.ente.io";

                description = ''
                  Set this to the URL where your accounts page is running.
                  This is primarily for passkey support.
                '';

                type = types.str;
              };

              cast = mkOption {
                default = "https://cast.ente.io";

                description = ''
                  Set this to the URL where your cast page is running.
                  This is for browser and chromecast casting support.
                '';

                type = types.str;
              };

              public-albums = mkOption {
                default = "https://albums.ente.io";

                description = ''
                  If you're running a self hosted instance and wish to serve public links,
                  set this to the URL where your albums web app is running.
                '';

                type = types.str;
              };
            };

            db = {
              host = mkOption {
                description = "The database host";
                type = types.str;
              };

              name = mkOption {
                description = "The database name";
                type = types.str;
              };

              port = mkOption {
                default = 5432;
                description = "The database port";
                type = types.port;
              };

              user = mkOption {
                description = "The database user";
                type = types.str;
              };
            };
          };

          freeformType = yamlFormat.type;
        };
      };

      user = mkOption {
        default = defaultUser;
        description = "User under which museum runs. If you set this option you must make sure the user exists.";
        type = types.str;
      };
    };

    web = {
      enable = mkEnableOption "Ente web frontend (Photos, Albums)";
      package = mkPackageOption pkgs "ente-web" { };

      domains = {
        accounts = mkOption {
          description = "The domain under which the accounts frontend will be served.";
          example = "accounts.ente.example.com";
          type = types.str;
        };

        albums = mkOption {
          description = "The domain under which the albums frontend will be served.";
          example = "albums.ente.example.com";
          type = types.str;
        };

        api = mkOption {
          description = ''
            The domain under which the api is served. This will NOT serve the api itself,
            but is a required setting to host the frontends! This will automatically be set
            for you if you enable both the api server and web frontends.
          '';

          example = "api.ente.example.com";
          type = types.str;
        };

        cast = mkOption {
          description = "The domain under which the cast frontend will be served.";
          example = "cast.ente.example.com";
          type = types.str;
        };

        photos = mkOption {
          description = "The domain under which the photos frontend will be served.";
          example = "photos.ente.example.com";
          type = types.str;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfgApi.enable {
      services.ente.api.settings = {
        db = mkIf cfgApi.enableLocalDB {
          host = "/run/postgresql";
          name = "ente";
          port = 5432;
          user = "ente";
        };

        # This will cause logs to be written to stdout/err, which then end up in the journal
        log-file = mkDefault "";
      };

      services.ente.web.domains.api = mkIf cfgWeb.enable cfgApi.domain;

      services.nginx = mkIf cfgApi.nginx.enable {
        enable = true;

        upstreams.museum = {
          extraConfig = ''
            zone museum 64k;
            keepalive 20;
          '';

          servers."localhost:8080" = { };
        };

        virtualHosts.${cfgApi.domain} = {
          extraConfig = ''
            client_max_body_size 4M;
          '';

          forceSSL = mkDefault true;
          locations."/".proxyPass = "http://museum";
        };
      };

      services.postgresql = mkIf cfgApi.enableLocalDB {
        enable = true;
        ensureDatabases = [ "ente" ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = "ente";
          }
        ];
      };

      systemd.services.ente = {
        after = [ "network.target" ] ++ optional cfgApi.enableLocalDB "postgresql.service";
        description = "Ente.io Museum API Server";

        # Environment MUST be called local, otherwise we cannot log to stdout
        environment = {
          ENVIRONMENT = "local";
          GIN_MODE = "release";
        };

        preStart = ''
          # Generate config including secret values. YAML is a superset of JSON, so we can use this here.
          ${utils.genJqSecretsReplacementSnippet cfgApi.settings "/run/ente/local.yaml"}

          # Setup paths
          mkdir -p ${dataDir}/configurations
          ln -sTf /run/ente/local.yaml ${dataDir}/configurations/local.yaml
        '';

        requires = optional cfgApi.enableLocalDB "postgresql.service";

        serviceConfig = {
          AmbientCapabilities = [ ];

          BindReadOnlyPaths = [
            "${cfgApi.package}/share/museum/migrations:${dataDir}/migrations"
            "${cfgApi.package}/share/museum/mail-templates:${dataDir}/mail-templates"
            "${cfgApi.package}/share/museum/web-templates:${dataDir}/web-templates"
          ];

          CapabilityBoundingSet = [ ];
          ExecStart = getExe cfgApi.package;
          Group = cfgApi.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = false;
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
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "ente";
          StateDirectory = "ente";
          SyslogIdentifier = "ente";
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service";
          Type = "simple";
          UMask = "077";
          User = cfgApi.user;
          WorkingDirectory = dataDir;
        };

        wantedBy = [ "multi-user.target" ];
      };

      users = {
        groups = mkIf (cfgApi.group == defaultGroup) { ${defaultGroup} = { }; };

        users = mkIf (cfgApi.user == defaultUser) {
          ${defaultUser} = {
            inherit (cfgApi) group;
            description = "ente.io museum service user";
            home = dataDir;
            isSystemUser = true;
          };
        };
      };
    })
    (mkIf cfgWeb.enable {
      services.ente.api.settings = mkIf cfgApi.enable {
        apps = {
          accounts = "https://${cfgWeb.domains.accounts}";
          cast = "https://${cfgWeb.domains.cast}";
          public-albums = "https://${cfgWeb.domains.albums}";
        };

        webauthn = {
          rpid = cfgWeb.domains.accounts;
          rporigins = [ "https://${cfgWeb.domains.accounts}" ];
        };
      };

      services.nginx =
        let
          domainFor = app: cfgWeb.domains.${app};
        in
        {
          enable = true;

          virtualHosts.${domainFor "accounts"} = {
            forceSSL = mkDefault true;

            locations."/" = {
              extraConfig = ''
                add_header Access-Control-Allow-Origin 'https://${cfgWeb.domains.api}';
              '';

              root = webPackage "accounts";
              tryFiles = "$uri $uri.html /index.html";
            };
          };

          virtualHosts.${domainFor "cast"} = {
            forceSSL = mkDefault true;

            locations."/" = {
              extraConfig = ''
                add_header Access-Control-Allow-Origin 'https://${cfgWeb.domains.api}';
              '';

              root = webPackage "cast";
              tryFiles = "$uri $uri.html /index.html";
            };
          };

          virtualHosts.${domainFor "photos"} = {
            forceSSL = mkDefault true;

            locations."/" = {
              extraConfig = ''
                add_header Access-Control-Allow-Origin 'https://${cfgWeb.domains.api}';
              '';

              root = webPackage "photos";
              tryFiles = "$uri $uri.html /index.html";
            };

            serverAliases = [
              (domainFor "albums") # the albums app is shared with the photos frontend
            ];
          };
        };
    })
  ];

  meta = {
    doc = ./ente.md;
    maintainers = with lib.maintainers; [ oddlama ];
  };
}

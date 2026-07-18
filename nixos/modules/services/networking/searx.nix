{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkDefault
    mkIf
    mkOption
    mkPackageOption
    mkRenamedOptionModule
    optionalAttrs
    types
    ;

  runDir = "/run/searx";

  cfg = config.services.searx;
  yamlFormat = pkgs.formats.yaml { };
  tomlFormat = pkgs.formats.toml { };

  settingsFile = yamlFormat.generate "settings.yml" (builtins.removeAttrs cfg.settings [ "redis" ]);

  faviconsSettingsFile = tomlFormat.generate "favicons.toml" cfg.faviconsSettings;
  limiterSettingsFile = tomlFormat.generate "limiter.toml" cfg.limiterSettings;

  generateConfig = ''
    cd ${runDir}

    # write NixOS settings
    (
      umask 077
      ${lib.getExe pkgs.envsubst} < ${settingsFile} > settings.yml
      ${
        if (cfg.faviconsSettings != { }) then
          "ln -sf ${faviconsSettingsFile} favicons.toml"
        else
          "rm -f favicons.toml"
      }
      ${
        if (cfg.limiterSettings != { }) then
          "ln -sf ${limiterSettingsFile} limiter.toml"
        else
          "rm -f limiter.toml"
      }
    )
  '';
in
{
  imports = [
    (mkRenamedOptionModule [ "services" "searx" "settingsFile" ] [ "services" "searx" "settingsPath" ])
    (mkRenamedOptionModule [ "services" "searx" "configFile" ] [ "services" "searx" "settingsFile" ])
    (mkRenamedOptionModule [ "services" "searx" "runInUwsgi" ] [ "services" "searx" "configureUwsgi" ])
  ];

  options = {
    services.searx = {
      enable = mkOption {
        default = false;
        description = "Whether to enable Searx, the meta search engine.";
        relatedPackages = [ "searx" ];
        type = types.bool;
      };

      package = mkPackageOption pkgs "searxng" { };

      configureNginx = mkOption {
        default = false;

        description = ''
          Whether to configure nginx as an frontend to uwsgi.
        '';

        type = types.bool;
      };

      configureUwsgi = mkOption {
        default = false;

        description = ''
          Whether to run searx in uWSGI as a "vassal", instead of using its
          built-in HTTP server. This is the recommended mode for public or
          large instances, but is unnecessary for LAN or local-only use.

          ::: {.warning}
          The built-in HTTP server logs all queries by default.
          :::
        '';

        type = types.bool;
      };

      domain = mkOption {
        description = ''
          The domain under which searxng will be served.
          Right now this is only used with the configureNginx option.
        '';

        type = types.str;
      };

      environmentFile = mkOption {
        default = null;

        description = ''
          Environment file (see {manpage}`systemd.exec(5)` "EnvironmentFile=" section for the syntax) to define variables for Searx.
          This option can be used to safely include secret keys into the Searx configuration.
        '';

        type = types.nullOr types.path;
      };

      faviconsSettings = mkOption {
        default = { };

        description = ''
          Favicons settings for SearXNG.

          ::: {.note}
          For available settings, see the SearXNG
          [schema file](https://github.com/searxng/searxng/blob/master/searx/favicons/favicons.toml).
          :::
        '';

        example = literalExpression ''
          {
            favicons = {
              cfg_schema = 1;
              cache = {
                db_url = "/var/cache/searx/faviconcache.db";
                HOLD_TIME = 5184000;
                LIMIT_TOTAL_BYTES = 2147483648;
                BLOB_MAX_BYTES = 40960;
                MAINTENANCE_MODE = "auto";
                MAINTENANCE_PERIOD = 600;
              };
            };
          }
        '';

        type = types.attrsOf tomlFormat.type;
      };

      limiterSettings = mkOption {
        default = { };

        description = ''
          Limiter settings for SearXNG.

          ::: {.note}
          For available settings, see the SearXNG [schema file](https://github.com/searxng/searxng/blob/master/searx/limiter.toml).
          :::
        '';

        example = literalExpression ''
          {
            botdetection = {
              ipv4_prefix = 32;
              ipv6_prefix = 56;

              trusted_proxies = [
                "127.0.0.0/8"
                "::1"
              ];

              ip_lists.block_ip = [
                # "93.184.216.34" # example.org
              ];
            };
          }
        '';

        type = types.attrsOf tomlFormat.type;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open the port in the firewall.
          Enabling this option adds the port specified in {option}`services.settings.server.port` to {option}`networking.firewall.allowedTCPPorts`.

          ::: {.note}
          When this option is set to true, {option}`services.settings.server.port` must be set as well or an error will be thrown.
          :::
        '';

        type = types.bool;
      };

      redisCreateLocally = mkOption {
        default = false;

        description = ''
          Configure a local Redis server for SearXNG.
          This is required if you want to enable the rate limiter and bot protection of SearXNG.
        '';

        type = types.bool;
      };

      settings = mkOption {
        default = { };

        description = ''
          Searx settings.
          These will be merged with (taking precedence over) the default configuration.
          It's also possible to refer to environment variables (defined in [](#opt-services.searx.environmentFile)) using the syntax `$VARIABLE_NAME`.

          ::: {.note}
          For available settings, see the Searx [docs](https://docs.searxng.org/admin/settings/index.html).
          :::
        '';

        example = literalExpression ''
          {
            server.port = 8080;
            server.bind_address = "0.0.0.0";
            server.secret_key = "$SEARX_SECRET_KEY";

            engines = [ {
              name = "wolframalpha";
              shortcut = "wa";
              api_key = "$WOLFRAM_API_KEY";
              engine = "wolframalpha_api";
            } ];
          }
        '';

        type = types.submodule (
          { config, ... }:
          {
            options = {
              valkey = lib.mkOption {
                default = { };
                internal = true;
              };
            };

            config.valkey = lib.mkIf (config ? redis) (
              lib.warn "Obsolete option `services.searx.settings.redis' is used. It was renamed to `services.searx.settings.valkey'" config.redis
            );

            freeformType = yamlFormat.type;
          }
        );
      };

      settingsPath = mkOption {
        default = runDir;

        description = ''
          The path of the SearXNG settings directory or the settings.yml file.
          If no path is specified, a default one is used (default config file has debug mode enabled).

          ::: {.note}
          Setting this options overrides [](#opt-services.searx.settings).
          :::

          ::: {.warning}
          This path, along with any secret keys it contains, will be copied into the world-readable Nix store.
          :::
        '';

        type = types.path;
      };

      uwsgiConfig = mkOption {
        inherit (options.services.uwsgi.instance) type;

        default = {
          http = ":8080";
        };

        description = ''
          Additional configuration of the uWSGI vassal running searx. It
          should notably specify on which interfaces and ports the vassal
          should listen.
        '';

        example = literalExpression ''
          {
            disable-logging = true;
            http = ":8080";                   # serve via HTTP...
            socket = "/run/searx/searx.sock"; # ...or UNIX socket
            chmod-socket = "660";             # allow the searx group to read/write to the socket
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.openFirewall -> cfg.settings ? server.port;
        message = "services.searx.settings.server.port must be set when openFirewall is enabled.";
      }
    ];

    environment.systemPackages = [ cfg.package ];
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.settings.server.port ]; };

    services = {
      nginx = lib.mkIf cfg.configureNginx {
        enable = true;

        virtualHosts."${cfg.domain}".locations = {
          "/" = {
            extraConfig = # nginx
              ''
                uwsgi_param  HTTP_HOST             $host;
                uwsgi_param  HTTP_CONNECTION       $http_connection;
                uwsgi_param  HTTP_X_SCHEME         $scheme;
                uwsgi_param  HTTP_X_SCRIPT_NAME    ""; # NOTE: When we ever make the path configurable, this must be set to anything not "/"!
                uwsgi_param  HTTP_X_REAL_IP        $remote_addr;
                uwsgi_param  HTTP_X_FORWARDED_FOR  $proxy_add_x_forwarded_for;
              '';

            recommendedProxySettings = true;
            recommendedUwsgiSettings = true;
            uwsgiPass = "unix:${config.services.uwsgi.instance.vassals.searx.socket}";
          };

          "/static/".alias = lib.mkDefault "${cfg.package}/share/static/";
        };
      };

      redis.servers.searx = lib.mkIf cfg.redisCreateLocally {
        enable = true;
        port = 0;
        user = "searx";
      };

      searx = {
        configureUwsgi = lib.mkIf cfg.configureNginx true;

        settings = {
          server.base_url = lib.mkIf cfg.configureNginx "http${
            lib.optionalString (lib.any lib.id (
              with config.services.nginx.virtualHosts."${cfg.domain}";
              [
                onlySSL
                addSSL
                forceSSL
              ]
            )) "s"
          }://${cfg.domain}/";

          # merge NixOS settings with defaults settings.yml
          use_default_settings = mkDefault true;

          valkey = lib.mkIf cfg.redisCreateLocally {
            url = "unix://${config.services.redis.servers.searx.unixSocket}";
          };
        };
      };

      uwsgi = mkIf cfg.configureUwsgi {
        enable = true;
        instance.type = "emperor";

        instance.vassals.searx = {
          buffer-size = 32768;
          enable-threads = true;

          env = [
            "SEARXNG_SETTINGS_PATH=${cfg.settingsPath}"
          ];

          immediate-gid = "searx";
          immediate-uid = "searx";
          lazy-apps = true;
          module = "searx.webapp";
          pythonPackages = _: [ cfg.package ];
          strict = true;
          type = "normal";
        }
        // lib.optionalAttrs cfg.configureNginx {
          chmod-socket = "660";
          socket = "/run/searx/uwsgi.sock";
        }
        // cfg.uwsgiConfig;

        plugins = [ "python3" ];
      };
    };

    systemd.services = {
      nginx = lib.mkIf cfg.configureNginx {
        serviceConfig.SupplementaryGroups = [ "searx" ];
      };

      searx = mkIf (!cfg.configureUwsgi) {
        after = [
          "searx-init.service"
          "network.target"
        ]
        ++ lib.optionals cfg.redisCreateLocally [ "redis-searx.service" ];

        description = "Searx server, the meta search engine.";

        environment = {
          SEARXNG_SETTINGS_PATH = cfg.settingsPath;
        };

        requires = [ "searx-init.service" ];

        serviceConfig = {
          CacheDirectory = "searx";
          CacheDirectoryMode = "0700";
          CapabilityBoundingSet = null;
          DevicePolicy = "closed";
          DynamicUser = true;
          ExecStart = lib.getExe cfg.package;
          Group = "searx";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateIPC = true;
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
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadOnlyPaths = [ cfg.settingsPath ];
          ReadWritePaths = lib.optional cfg.redisCreateLocally config.services.redis.servers.searx.unixSocket;
          RemoveIPC = true;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";

          SystemCallFilter = [
            "@system-service"
            "~@privileged @resources"
          ];

          UMask = "0077";
          User = "searx";
        }
        // optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };

        wantedBy = [ "multi-user.target" ];
      };

      searx-init = {
        description = "Initialise Searx settings";
        script = generateConfig;

        serviceConfig = {
          RemainAfterExit = true;
          RuntimeDirectory = "searx";
          RuntimeDirectoryMode = "750";
          RuntimeDirectoryPreserve = "yes";
          Type = "oneshot";
          User = "searx";
        }
        // optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };
      };

      uwsgi = mkIf cfg.configureUwsgi {
        after = [ "searx-init.service" ];
        requires = [ "searx-init.service" ];

        restartTriggers = [
          cfg.package
          cfg.settingsPath
        ]
        ++ lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      };
    };

    users = {
      groups.searx = { };

      users.searx = {
        description = "Searx daemon user";
        group = "searx";
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    SuperSandro2000
    _999eagle
  ];
}

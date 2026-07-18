{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    concatMapStringsSep
    escapeShellArgs
    filter
    filterAttrs
    getExe
    getExe'
    isAttrs
    isList
    literalExpression
    mapAttrs
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionals
    recursiveUpdate
    types
    ;

  filterRecursiveNull =
    o:
    if isAttrs o then
      mapAttrs (_: v: filterRecursiveNull v) (filterAttrs (_: v: v != null) o)
    else if isList o then
      map filterRecursiveNull (filter (v: v != null) o)
    else
      o;

  cfg = config.services.pretix;
  format = pkgs.formats.ini { };

  configFile = format.generate "pretix.cfg" (filterRecursiveNull cfg.settings);

  finalPackage = cfg.package.override {
    inherit (cfg) plugins;
  };

  pythonEnv = cfg.package.python.buildEnv.override {
    extraLibs =
      with cfg.package.python.pkgs;
      [
        (toPythonModule finalPackage)
        gunicorn
      ]
      ++ lib.optionals (
        cfg.settings.memcached.location != null
      ) cfg.package.optional-dependencies.memcached;
  };

  withRedis = cfg.settings.redis.location != null;

  pretixManageWrapper = pkgs.writeShellApplication {
    name = "pretix-manage";

    runtimeInputs = with pkgs; [
      util-linux
    ];

    text = ''
      cd ${cfg.settings.pretix.datadir}
      export PRETIX_CONFIG_FILE=${configFile}
      exec runuser ${
        lib.cli.toCommandLineShellGNU { } {
          inherit (cfg) user;
          supp-group = if withRedis then config.services.redis.servers.pretix.group else null;
          whitelist-environment = "PRETIX_CONFIG_FILE";
        }
      } -- ${getExe' pythonEnv "pretix-manage"} "$@"
    '';
  };
in
{
  options.services.pretix = {
    enable = mkEnableOption "Pretix, a ticket shop application for conferences, festivals, concerts, etc";
    package = mkPackageOption pkgs "pretix" { };

    celery = {
      extraArgs = mkOption {
        apply = utils.escapeSystemdExecArgs;
        default = [ ];

        description = ''
          Extra arguments to pass to celery.

          See <https://docs.celeryq.dev/en/stable/reference/cli.html#celery-worker> for more info.
        '';

        type = with types; listOf str;
      };
    };

    database.createLocally = mkOption {
      default = true;

      description = ''
        Whether to automatically set up the database on the local DBMS instance.

        Only supported for PostgreSQL. Not required for sqlite.
      '';

      example = false;
      type = types.bool;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file to pass secret configuration values.

        Each line must follow the `PRETIX_SECTION_KEY=value` pattern.
      '';

      example = "/run/keys/pretix-secrets.env";
      type = types.nullOr types.path;
    };

    group = mkOption {
      default = "pretix";

      description = ''
        Group under which pretix should run.
      '';

      type = types.str;
    };

    gunicorn.extraArgs = mkOption {
      apply = escapeShellArgs;

      default = [
        "--name=pretix"
      ];

      description = ''
        Extra arguments to pass to gunicorn.
        See <https://docs.pretix.eu/en/latest/admin/installation/manual_smallscale.html#start-pretix-as-a-service> for details.
      '';

      example = [
        "--name=pretix"
        "--workers=4"
        "--max-requests=1200"
        "--max-requests-jitter=50"
        "--log-level=info"
      ];

      type = with types; listOf str;
    };

    nginx = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to set up an nginx virtual host.
        '';

        example = false;
        type = types.bool;
      };

      domain = mkOption {
        description = ''
          The domain name under which to set up the virtual host.
        '';

        example = "talks.example.com";
        type = types.str;
      };
    };

    plugins = mkOption {
      default = [ ];

      description = ''
        Pretix plugins to install into the Python environment.
      '';

      example = literalExpression ''
        with config.services.pretix.package.plugins; [
          passbook
          pages
        ];
      '';

      type = types.listOf types.package;
    };

    settings = mkOption {
      default = { };

      description = ''
        pretix configuration as a Nix attribute set. All settings can also be passed
        from the environment.

        See <https://docs.pretix.eu/en/latest/admin/config.html> for possible options.
      '';

      type = types.submodule {
        options = {
          celery = {
            backend = mkOption {
              default = "redis+socket://${config.services.redis.servers.pretix.unixSocket}?virtual_host=1";

              defaultText = literalExpression ''
                redis+socket://''${config.services.redis.servers.pretix.unixSocket}?virtual_host=1
              '';

              description = ''
                URI to the celery backend used for the asynchronous job queue.
              '';

              type = types.str;
            };

            broker = mkOption {
              default = "redis+socket://${config.services.redis.servers.pretix.unixSocket}?virtual_host=2";

              defaultText = literalExpression ''
                redis+socket://''${config.services.redis.servers.pretix.unixSocket}?virtual_host=2
              '';

              description = ''
                URI to the celery broker used for the asynchronous job queue.
              '';

              type = types.str;
            };
          };

          database = {
            backend = mkOption {
              default = "postgresql";

              description = ''
                Database backend to use.

                Only postgresql is recommended for production setups.
              '';

              type = types.enum [
                "sqlite3"
                "postgresql"
              ];
            };

            host = mkOption {
              default = if cfg.settings.database.backend == "postgresql" then "/run/postgresql" else null;

              defaultText = literalExpression ''
                if config.services.pretix.settings..database.backend == "postgresql" then "/run/postgresql"
                else null
              '';

              description = ''
                Database host or socket path.
              '';

              type = with types; nullOr str;
            };

            name = mkOption {
              default = "pretix";

              description = ''
                Database name.
              '';

              type = types.str;
            };

            user = mkOption {
              default = "pretix";

              description = ''
                Database username.
              '';

              type = types.str;
            };
          };

          mail = {
            from = mkOption {
              description = ''
                E-Mail address used in the `FROM` header of outgoing mails.
              '';

              example = "tickets@example.com";
              type = types.str;
            };

            host = mkOption {
              default = "localhost";

              description = ''
                Hostname of the SMTP server use for mail delivery.
              '';

              example = "mail.example.com";
              type = types.str;
            };

            port = mkOption {
              default = 25;

              description = ''
                Port of the SMTP server to use for mail delivery.
              '';

              example = 587;
              type = types.port;
            };
          };

          memcached = {
            location = mkOption {
              default = null;

              description = ''
                The `host:port` combination or the path to the UNIX socket of a memcached instance.

                Can be used instead of Redis for caching.
              '';

              example = "127.0.0.1:11211";
              type = with types; nullOr str;
            };
          };

          pretix = {
            cachedir = mkOption {
              default = "/var/cache/pretix";

              description = ''
                Directory for storing temporary files.
              '';

              type = types.path;
            };

            currency = mkOption {
              default = "EUR";

              description = ''
                Default currency for events in its ISO 4217 three-letter code.
              '';

              example = "USD";
              type = types.str;
            };

            datadir = mkOption {
              default = "/var/lib/pretix";

              description = ''
                Directory for storing user uploads and similar data.
              '';

              type = types.path;
            };

            instance_name = mkOption {
              description = ''
                The name of this installation.
              '';

              example = "tickets.example.com";
              type = types.str;
            };

            logdir = mkOption {
              default = "/var/log/pretix";

              description = ''
                Directory for storing log files.
              '';

              type = types.path;
            };

            registration = mkOption {
              default = false;

              description = ''
                Whether to allow registration of new admin users.
              '';

              example = true;
              type = types.bool;
            };

            url = mkOption {
              description = ''
                The installation’s full URL, without a trailing slash.
              '';

              example = "https://tickets.example.com";
              type = types.str;
            };
          };

          redis = {
            location = mkOption {
              default = "unix://${config.services.redis.servers.pretix.unixSocket}?db=0";

              defaultText = literalExpression ''
                "unix://''${config.services.redis.servers.pretix.unixSocket}?db=0"
              '';

              description = ''
                URI to the redis server, used to speed up locking, caching and session storage.
              '';

              type = with types; nullOr str;
            };

            sessions = mkOption {
              default = true;

              description = ''
                Whether to use redis as the session storage.
              '';

              example = false;
              type = types.bool;
            };
          };

          tools = {
            pdftk = mkOption {
              default = getExe pkgs.pdftk;

              defaultText = literalExpression ''
                lib.getExe pkgs.pdftk
              '';

              description = ''
                Path to the pdftk executable.
              '';

              type = types.path;
            };
          };
        };

        freeformType = format.type;
      };
    };

    user = mkOption {
      default = "pretix";

      description = ''
        User under which pretix should run.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # https://docs.pretix.eu/en/latest/admin/installation/index.html
    environment.systemPackages = [
      pretixManageWrapper
    ];

    services = {
      nginx = mkIf cfg.nginx.enable {
        enable = true;
        recommendedGzipSettings = mkDefault true;
        recommendedOptimisation = mkDefault true;
        recommendedProxySettings = mkDefault true;
        recommendedTlsSettings = mkDefault true;
        upstreams.pretix.servers."unix:/run/pretix/pretix.sock" = { };

        virtualHosts.${cfg.nginx.domain} = {
          # https://docs.pretix.eu/en/latest/admin/installation/manual_smallscale.html#ssl
          extraConfig = ''
            more_set_headers Referrer-Policy same-origin;
            more_set_headers X-Content-Type-Options nosniff;
          '';

          locations = {
            "/".proxyPass = "http://pretix";

            "/media/" = {
              alias = "${cfg.settings.pretix.datadir}/media/";

              extraConfig = ''
                access_log off;
                expires 7d;
              '';
            };

            "/static/" = {
              alias = "${finalPackage}/${cfg.package.python.sitePackages}/pretix/static.dist/";

              extraConfig = ''
                access_log off;
                more_set_headers Cache-Control "public";
                expires 365d;
              '';
            };

            "^~ (/media/(cachedfiles|invoices)|/static/(staticfiles.json|CACHE/manifest.json))" = {
              extraConfig = ''
                deny all;
                return 404;
              '';
            };
          };
        };
      };

      postgresql = mkIf (cfg.database.createLocally && cfg.settings.database.backend == "postgresql") {
        enable = true;
        ensureDatabases = [ cfg.settings.database.name ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = cfg.settings.database.user;
          }
        ];
      };

      redis.servers.pretix.enable = withRedis;
    };

    services.logrotate.settings.pretix = {
      compress = true;
      copytruncate = true;
      files = "${cfg.settings.pretix.logdir}/*.log";
      frequency = "weekly";
      rotate = "12";
      su = "${cfg.user} ${cfg.group}";
    };

    systemd.services =
      let
        commonUnitConfig = {
          environment.PRETIX_CONFIG_FILE = configFile;

          serviceConfig = {
            AmbientCapabilities = "";
            CacheDirectory = "pretix";
            CapabilityBoundingSet = [ "" ];
            DevicePolicy = "closed";

            EnvironmentFile = optionals (cfg.environmentFile != null) [
              cfg.environmentFile
            ];

            Group = "pretix";
            LockPersonality = true;
            LogsDirectory = "pretix";
            MemoryDenyWriteExecute = false; # required by pdftk
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProcSubset = "pid";
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RemoveIPC = true;

            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;

            StateDirectory = [
              "pretix"
            ];

            StateDirectoryMode = "0750";

            SupplementaryGroups = optionals withRedis [
              "redis-pretix"
            ];

            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged"
              "@chown"
            ];

            UMask = "0027";
            User = "pretix";
            WorkingDirectory = cfg.settings.pretix.datadir;
          };
        };
      in
      {
        nginx.serviceConfig.SupplementaryGroups = mkIf cfg.nginx.enable [ "pretix" ];

        pretix-periodic = recursiveUpdate commonUnitConfig {
          description = "pretix periodic task runner";

          serviceConfig = {
            ExecStart = "${getExe' pythonEnv "pretix-manage"} runperiodic";
            Type = "oneshot";
          };

          # every 15 minutes
          startAt = [ "*:3,18,33,48" ];
        };

        pretix-web = recursiveUpdate commonUnitConfig {
          after = [
            "network.target"
            "redis-pretix.service"
            "postgresql.target"
          ];

          description = "pretix web service";

          preStart = ''
            versionFile="${cfg.settings.pretix.datadir}/.version"
            version=$(cat "$versionFile" 2>/dev/null || echo 0)

            pluginsFile="${cfg.settings.pretix.datadir}/.plugins"
            plugins=$(cat "$pluginsFile" 2>/dev/null || echo "")
            configuredPlugins="${concatMapStringsSep "|" (package: package.name) cfg.plugins}"

            if [[ $version != ${cfg.package.version} || $plugins != $configuredPlugins ]]; then
              ${getExe' pythonEnv "pretix-manage"} migrate

              echo "${cfg.package.version}" > "$versionFile"
              echo "$configuredPlugins" > "$pluginsFile"
            fi
          '';

          serviceConfig = {
            ExecStart = "${getExe' pythonEnv "gunicorn"} --bind unix:/run/pretix/pretix.sock ${cfg.gunicorn.extraArgs} pretix.wsgi";
            Restart = "on-failure";
            RuntimeDirectory = "pretix";
            TimeoutStartSec = "15min";
          };

          wantedBy = [ "multi-user.target" ];
        };

        pretix-worker = recursiveUpdate commonUnitConfig {
          after = [
            "network.target"
            "redis-pretix.service"
            "postgresql.target"
          ];

          description = "pretix asynchronous job runner";

          serviceConfig = {
            ExecStart = "${getExe' pythonEnv "celery"} -A pretix.celery_app worker ${cfg.celery.extraArgs}";
            Restart = "on-failure";
          };

          wantedBy = [ "multi-user.target" ];
        };
      };

    systemd.sockets.pretix-web.socketConfig = {
      ListenStream = "/run/pretix/pretix.sock";
      SocketUser = "nginx";
    };

    users = {
      groups.${cfg.group} = { };

      users.${cfg.user} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ hexa ];
  };
}

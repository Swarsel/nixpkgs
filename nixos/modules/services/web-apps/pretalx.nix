{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.pretalx;
  format = pkgs.formats.ini { };

  configFile = format.generate "pretalx.cfg" cfg.settings;

  inherit (cfg) finalPackage;

  pythonEnv = finalPackage.python.buildEnv.override {
    extraLibs =
      with finalPackage.python.pkgs;
      [
        (toPythonModule finalPackage)
        gunicorn
      ]
      ++ lib.optionals (
        cfg.settings.database.backend == "postgresql"
      ) finalPackage.optional-dependencies.postgres;
  };

  pretalxManageWrapper = pkgs.writeShellApplication {
    excludeShellChecks = [
      # Not following: /run/agenix/pretalx-env was not specified as input
      "SC1091"
    ];

    name = "pretalx-manage";

    runtimeInputs = with pkgs; [
      util-linux
    ];

    text = ''
      cd ${cfg.settings.filesystem.data}
      set -a
      ${lib.concatMapStringsSep "\n" (file: ''
        . ${lib.escapeShellArg file}
      '') cfg.environmentFiles}
      set +a
      export PRETALX_CONFIG_FILE=${configFile}
      exec runuser ${
        lib.cli.toCommandLineShellGNU { } {
          inherit (cfg) user;
          preserve-environment = true;
        }
      } -- ${lib.getExe' pythonEnv "pretalx-manage"} "$@"
    '';
  };
in

{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "pretalx" "celery" "enable" ] ''
      Celery is now always required.
    '')
  ];

  options.services.pretalx = {
    enable = lib.mkEnableOption "pretalx";
    package = lib.mkPackageOption pkgs "pretalx" { };

    celery = {
      extraArgs = lib.mkOption {
        apply = utils.escapeSystemdExecArgs;
        default = [ ];

        description = ''
          Extra arguments to pass to celery.

          See <https://docs.celeryq.dev/en/stable/reference/cli.html#celery-worker> for more info.
        '';

        type = with lib.types; listOf str;
      };
    };

    database.createLocally = lib.mkOption {
      default = true;

      description = ''
        Whether to automatically set up the database on the local DBMS instance.

        Currently only supported for PostgreSQL. Not required for sqlite.
      '';

      example = false;
      type = lib.types.bool;
    };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Environment files that allow passing secret configuration values.

        Each line must follow the `PRETALX_SECTION_KEY=value` pattern.
      '';

      example = [ "/run/secrets/pretalx/env" ];
      type = lib.types.listOf lib.types.path;
    };

    finalPackage = lib.mkOption {
      default = cfg.package.override {
        inherit (cfg) plugins;
      };

      defaultText = ''
        config.services.package.override {
          inherit (config.services.pretalx) plugins;
        }
      '';

      description = ''
        The effective pretalx package used. This is the base package with the selected plugins applied.
      '';

      readOnly = true;
      type = lib.types.package;
    };

    group = lib.mkOption {
      default = "pretalx";
      description = "Group under which pretalx should run.";
      type = lib.types.str;
    };

    gunicorn.extraArgs = lib.mkOption {
      apply = lib.escapeShellArgs;

      default = [
        "--name=pretalx"
      ];

      description = ''
        Extra arguments to pass to gunicorn.
        See <https://docs.pretalx.org/administrator/installation.html#step-6-starting-pretalx-as-a-service> for details.
      '';

      example = [
        "--name=pretalx"
        "--workers=4"
        "--max-requests=1200"
        "--max-requests-jitter=50"
        "--log-level=info"
      ];

      type = with lib.types; listOf str;
    };

    nginx = {
      enable = lib.mkOption {
        default = true;

        description = ''
          Whether to set up an nginx virtual host.
        '';

        example = false;
        type = lib.types.bool;
      };

      domain = lib.mkOption {
        description = ''
          The domain name under which to set up the virtual host.
        '';

        example = "talks.example.com";
        type = lib.types.str;
      };
    };

    plugins = lib.mkOption {
      default = [ ];

      description = ''
        Pretalx plugins to install into the Python environment.
      '';

      example = lib.literalExpression ''
        with config.services.pretalx.package.plugins; [
          pages
          youtube
        ];
      '';

      type = with lib.types; listOf package;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        pretalx configuration as a Nix attribute set. All settings can also be passed
        from the environment.

        See <https://docs.pretalx.org/administrator/configure.html> for possible options.
      '';

      type = lib.types.submodule {
        options = {
          celery = {
            backend = lib.mkOption {
              default = "redis+socket://${config.services.redis.servers.pretalx.unixSocket}?virtual_host=1";
              defaultText = lib.literalExpression "redis+socket://\${config.services.redis.servers.pretalx.unixSocket}?virtual_host=1";

              description = ''
                URI to the celery backend used for the asynchronous job queue.
              '';

              type = with lib.types; nullOr str;
            };

            broker = lib.mkOption {
              default = "redis+socket://${config.services.redis.servers.pretalx.unixSocket}?virtual_host=2";
              defaultText = lib.literalExpression "redis+socket://\${config.services.redis.servers.pretalx.unixSocket}?virtual_host=2";

              description = ''
                URI to the celery broker used for the asynchronous job queue.
              '';

              type = with lib.types; nullOr str;
            };
          };

          database = {
            backend = lib.mkOption {
              default = "postgresql";

              description = ''
                Database backend to use.

                Currently only PostgreSQL gets tested, and as such we don't support any other DBMS.
              '';

              readOnly = true; # only postgres supported right now

              type = lib.types.enum [
                "postgresql"
              ];
            };

            host = lib.mkOption {
              default =
                if cfg.settings.database.backend == "postgresql" then
                  "/run/postgresql"
                else if cfg.settings.database.backend == "mysql" then
                  "/run/mysqld/mysqld.sock"
                else
                  null;

              defaultText = lib.literalExpression ''
                if config.services.pretalx.settings..database.backend == "postgresql" then "/run/postgresql"
                else if config.services.pretalx.settings.database.backend == "mysql" then "/run/mysqld/mysqld.sock"
                else null
              '';

              description = ''
                Database host or socket path.
              '';

              type = with lib.types; nullOr types.path;
            };

            name = lib.mkOption {
              default = "pretalx";

              description = ''
                Database name.
              '';

              type = lib.types.str;
            };

            user = lib.mkOption {
              default = "pretalx";

              description = ''
                Database username.
              '';

              type = lib.types.str;
            };
          };

          files = {
            upload_limit = lib.mkOption {
              default = 10;

              description = ''
                Maximum file upload size in MiB.
              '';

              example = 50;
              type = lib.types.ints.positive;
            };
          };

          filesystem = {
            data = lib.mkOption {
              default = "/var/lib/pretalx";

              description = ''
                Base path for all other storage paths.
              '';

              type = lib.types.path;
            };

            logs = lib.mkOption {
              default = "/var/log/pretalx";

              description = ''
                Path to the log directory, that pretalx logs message to.
              '';

              type = lib.types.path;
            };

            static = lib.mkOption {
              default = "${finalPackage.static}/";
              defaultText = "\${config.services.pretalx.finalPackage.static}/";

              description = ''
                Path to the directory that contains static files.
              '';

              readOnly = true;
              type = lib.types.path;
            };
          };

          redis = {
            location = lib.mkOption {
              default = "unix://${config.services.redis.servers.pretalx.unixSocket}?db=0";

              defaultText = lib.literalExpression ''
                "unix://''${config.services.redis.servers.pretalx.unixSocket}?db=0"
              '';

              description = ''
                URI to the redis server, used to speed up locking, caching and session storage.
              '';

              type = with lib.types; nullOr str;
            };

            session = lib.mkOption {
              default = true;

              description = ''
                Whether to use redis as the session storage.
              '';

              example = false;
              type = lib.types.bool;
            };
          };

          site = {
            url = lib.mkOption {
              default = "https://${cfg.nginx.domain}";
              defaultText = lib.literalExpression "https://\${config.services.pretalx.nginx.domain}";

              description = ''
                The base URI below which your pretalx instance will be reachable.
              '';

              example = "https://talks.example.com";
              type = lib.types.str;
            };
          };
        };

        freeformType = format.type;
      };
    };

    user = lib.mkOption {
      default = "pretalx";
      description = "User under which pretalx should run.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # https://docs.pretalx.org/administrator/installation/
    environment.systemPackages = [
      pretalxManageWrapper
    ];

    services = {
      nginx = lib.mkIf cfg.nginx.enable {
        enable = true;
        recommendedGzipSettings = lib.mkDefault true;
        recommendedOptimisation = lib.mkDefault true;
        recommendedProxySettings = lib.mkDefault true;
        recommendedTlsSettings = lib.mkDefault true;
        upstreams.pretalx.servers."unix:/run/pretalx/pretalx.sock" = { };

        virtualHosts.${cfg.nginx.domain} = {
          # https://docs.pretalx.org/administrator/installation/#step-8-reverse-proxy
          extraConfig = ''
            more_set_headers "Referrer-Policy: same-origin";
            more_set_headers "X-Content-Type-Options: nosniff";
          '';

          locations = {
            "/".proxyPass = "http://pretalx";

            "/media/" = {
              alias = "${cfg.settings.filesystem.data}/media/";

              extraConfig = ''
                access_log off;
                more_set_headers 'Content-Disposition: attachment; filename="$1"';
                expires 7d;
                types {
                  # prevent xss through file uploads
                  text/plain html;
                  text/plain htm;
                  text/plain svg;
                  text/plain svgz;
                  text/plain js;
                  text/plain mjs;
                }
              '';
            };

            "/static/" = {
              alias = cfg.settings.filesystem.static;

              extraConfig = ''
                access_log off;
                more_set_headers Cache-Control "public";
                expires 365d;
              '';
            };
          };
        };
      };

      postgresql =
        lib.mkIf (cfg.database.createLocally && cfg.settings.database.backend == "postgresql")
          {
            enable = true;
            ensureDatabases = [ cfg.settings.database.name ];

            ensureUsers = [
              {
                ensureDBOwnership = true;
                name = cfg.settings.database.user;
              }
            ];
          };

      redis.servers.pretalx.enable = true;
    };

    services.logrotate.settings.pretalx = {
      compress = true;
      copytruncate = true;
      files = "${cfg.settings.filesystem.logs}/*.log";
      frequency = "weekly";
      rotate = "12";
      su = "${cfg.user} ${cfg.group}";
    };

    systemd.services =
      let
        commonUnitConfig = {
          environment.PRETALX_CONFIG_FILE = configFile;

          serviceConfig = {
            AmbientCapabilities = "";
            CapabilityBoundingSet = [ "" ];
            DevicePolicy = "closed";
            EnvironmentFile = cfg.environmentFiles;
            Group = "pretalx";
            LockPersonality = true;
            LogsDirectory = "pretalx";
            MemoryDenyWriteExecute = true;
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
              "pretalx"
              "pretalx/media"
            ];

            StateDirectoryMode = "0750";
            SupplementaryGroups = [ "redis-pretalx" ];
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged"
              "@chown"
            ];

            UMask = "0027";
            User = "pretalx";
            WorkingDirectory = cfg.settings.filesystem.data;
          };
        };
      in
      {
        nginx.serviceConfig.SupplementaryGroups = lib.mkIf cfg.nginx.enable [ "pretalx" ];

        pretalx-clear-sessions = lib.recursiveUpdate commonUnitConfig {
          description = "pretalx session pruning";

          serviceConfig = {
            ExecStart = "${lib.getExe' pythonEnv "pretalx-manage"} clearsessions";
            Type = "oneshot";
          };

          startAt = [ "monthly" ];
        };

        pretalx-periodic = lib.recursiveUpdate commonUnitConfig {
          description = "pretalx periodic task runner";

          serviceConfig = {
            ExecStart = "${lib.getExe' pythonEnv "pretalx-manage"} runperiodic";
            Type = "oneshot";
          };

          # every 15 minutes
          startAt = [ "*:3,18,33,48" ];
        };

        pretalx-web = lib.recursiveUpdate commonUnitConfig {
          after = [
            "network.target"
            "redis-pretalx.service"
          ]
          ++ lib.optionals (cfg.settings.database.backend == "postgresql") [
            "postgresql.target"
          ]
          ++ lib.optionals (cfg.settings.database.backend == "mysql") [
            "mysql.service"
          ];

          description = "pretalx web service";

          preStart =
            let
              versionString = lib.concatStringsSep "\n" (
                [ "pretalx-${finalPackage.version}" ]
                ++ map (plugin: "${plugin.pname}-${plugin.version}") cfg.plugins
              );
            in
            ''
              versionFile="${cfg.settings.filesystem.data}/.version"
              version="$(cat "$versionFile" 2>/dev/null || echo 0)"

              if [[ "$version" != "${versionString}" ]]; then
                ${lib.getExe' pythonEnv "pretalx-manage"} migrate

                echo "${versionString}" > "$versionFile"
              fi
            '';

          serviceConfig = {
            ExecStart = "${lib.getExe' pythonEnv "gunicorn"} --bind unix:/run/pretalx/pretalx.sock ${cfg.gunicorn.extraArgs} pretalx.wsgi";
            RuntimeDirectory = "pretalx";
          };

          wantedBy = [ "multi-user.target" ];
        };

        pretalx-worker = lib.recursiveUpdate commonUnitConfig {
          after = [
            "network.target"
            "redis-pretalx.service"
          ]
          ++ lib.optionals (cfg.settings.database.backend == "postgresql") [
            "postgresql.target"
          ]
          ++ lib.optionals (cfg.settings.database.backend == "mysql") [
            "mysql.service"
          ];

          description = "pretalx asynchronous job runner";
          serviceConfig.ExecStart = "${lib.getExe' pythonEnv "celery"} -A pretalx.celery_app worker ${cfg.celery.extraArgs}";
          wantedBy = [ "multi-user.target" ];
        };
      };

    systemd.sockets.pretalx-web.socketConfig = {
      ListenStream = "/run/pretalx/pretalx.sock";
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

  meta.maintainers = pkgs.pretalx.meta.maintainers;
}

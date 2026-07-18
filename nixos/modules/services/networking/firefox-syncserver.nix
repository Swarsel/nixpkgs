{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.firefox-syncserver;
  opt = options.services.firefox-syncserver;
  defaultDatabase = "firefox_syncserver";
  defaultUser = "firefox-syncserver";

  dbIsLocal = cfg.database.host == "localhost";
  dbURL = "mysql://${cfg.database.user}@${cfg.database.host}/${cfg.database.name}${lib.optionalString dbIsLocal "?socket=/run/mysqld/mysqld.sock"}";

  format = pkgs.formats.toml { };
  settings = {
    human_logs = true;

    syncstorage = {
      database_url = dbURL;
    };

    tokenserver = {
      # if JWK caching is not enabled the token server must verify tokens
      # using the fxa api, on a thread pool with a static size.
      additional_blocking_threads_for_fxa_requests = 10;
      database_url = dbURL;
      fxa_email_domain = "api.accounts.firefox.com";
      fxa_oauth_server_url = "https://oauth.accounts.firefox.com/v1";
      node_type = "mysql";
      run_migrations = true;
    }
    // lib.optionalAttrs cfg.singleNode.enable {
      # Single-node mode is likely to be used on small instances with little
      # capacity. The default value (0.1) can only ever release capacity when
      # accounts are removed if the total capacity is 10 or larger to begin
      # with.
      # https://github.com/mozilla-services/syncstorage-rs/issues/1313#issuecomment-1145293375
      node_capacity_release_rate = 1;
    };
  };
  configFile = format.generate "syncstorage.toml" (lib.recursiveUpdate settings cfg.settings);
  setupScript = pkgs.writeShellScript "firefox-syncserver-setup" ''
    set -euo pipefail
    shopt -s inherit_errexit

    schema_configured() {
      mysql ${cfg.database.name} -Ne 'SHOW TABLES' | grep -q services
    }

    update_config() {
      mysql ${cfg.database.name} <<"EOF"
        BEGIN;

        INSERT INTO `services` (`id`, `service`, `pattern`)
          VALUES (1, 'sync-1.5', '{node}/1.5/{uid}')
          ON DUPLICATE KEY UPDATE service='sync-1.5', pattern='{node}/1.5/{uid}';
        INSERT INTO `nodes` (`id`, `service`, `node`, `available`, `current_load`,
                             `capacity`, `downed`, `backoff`)
          VALUES (1, 1, '${cfg.singleNode.url}', ${toString cfg.singleNode.capacity},
          0, ${toString cfg.singleNode.capacity}, 0, 0)
          ON DUPLICATE KEY UPDATE node = '${cfg.singleNode.url}', capacity=${toString cfg.singleNode.capacity};

        COMMIT;
    EOF
    }


    for (( try = 0; try < 60; try++ )); do
      if ! schema_configured; then
        sleep 2
      else
        update_config
        exit 0
      fi
    done

    echo "Single-node setup failed"
    exit 1
  '';
in

{
  options = {
    services.firefox-syncserver = {
      enable = lib.mkEnableOption ''
        the Firefox Sync storage service.

        Out of the box this will not be very useful unless you also configure at least
        one service and one nodes by inserting them into the mysql database manually, e.g.
        by running

        ```
          INSERT INTO `services` (`id`, `service`, `pattern`) VALUES ('1', 'sync-1.5', '{node}/1.5/{uid}');
          INSERT INTO `nodes` (`id`, `service`, `node`, `available`, `current_load`,
              `capacity`, `downed`, `backoff`)
            VALUES ('1', '1', 'https://mydomain.tld', '1', '0', '10', '0', '0');
        ```

        {option}`${opt.singleNode.enable}` does this automatically when enabled
      '';

      package = lib.mkPackageOption pkgs "syncstorage-rs" { };

      database.createLocally = lib.mkOption {
        default = true;

        description = ''
          Whether to create database and user on the local machine if they do not exist.
          This includes enabling unix domain socket authentication for the configured user.
        '';

        type = lib.types.bool;
      };

      database.host = lib.mkOption {
        default = "localhost";

        description = ''
          Database host name. `localhost` is treated specially and inserts
          systemd dependencies, other hostnames or IP addresses of the local machine do not.
        '';

        type = lib.types.str;
      };

      database.name = lib.mkOption {
        default = defaultDatabase;

        description = ''
          Database to use for storage. Will be created automatically if it does not exist
          and `config.${opt.database.createLocally}` is set.
        '';

        # the mysql module does not allow `-quoting without resorting to shell
        # escaping, so we restrict db names for forward compaitiblity should this
        # behavior ever change.
        type = lib.types.strMatching "[a-z_][a-z0-9_]*";
      };

      database.user = lib.mkOption {
        default = defaultUser;

        description = ''
          Username for database connections.
        '';

        type = lib.types.str;
      };

      logLevel = lib.mkOption {
        default = "error";

        description = ''
          Log level to run with. This can be a simple log level like `error`
          or `trace`, or a more complicated logging expression.
        '';

        type = lib.types.str;
      };

      secrets = lib.mkOption {
        description = ''
          A file containing the various secrets. Should be in the format expected by systemd's
          `EnvironmentFile` directory. Two secrets are currently available:
          `SYNC_MASTER_SECRET` and
          `SYNC_TOKENSERVER__FXA_METRICS_HASH_SECRET`.
        '';

        type = lib.types.path;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Settings for the sync server. These take priority over values computed
          from NixOS options.

          See the example config in
          <https://github.com/mozilla-services/syncstorage-rs/blob/master/config/local.example.toml>
          and the doc comments on the `Settings` structs in
          <https://github.com/mozilla-services/syncstorage-rs/blob/master/syncstorage-settings/src/lib.rs>
          and
          <https://github.com/mozilla-services/syncstorage-rs/blob/master/tokenserver-settings/src/lib.rs>
          for available options.
        '';

        type = lib.types.submodule {
          options = {
            port = lib.mkOption {
              default = 5000;

              description = ''
                Port to bind to.
              '';

              type = lib.types.port;
            };

            tokenserver.enabled = lib.mkOption {
              default = true;

              description = ''
                Whether to enable the token service as well.
              '';

              type = lib.types.bool;
            };
          };

          freeformType = format.type;
        };
      };

      singleNode = {
        enable = lib.mkEnableOption "auto-configuration for a simple single-node setup";

        capacity = lib.mkOption {
          default = 10;

          description = ''
            How many sync accounts are allowed on this server. Setting this value
            equal to or less than the number of currently active accounts will
            effectively deny service to accounts not yet registered here.
          '';

          type = lib.types.ints.unsigned;
        };

        enableNginx = lib.mkEnableOption "nginx virtualhost definitions";
        enableTLS = lib.mkEnableOption "automatic TLS setup";

        hostname = lib.mkOption {
          description = ''
            Host name to use for this service.
          '';

          type = lib.types.str;
        };

        url = lib.mkOption {
          default = "${if cfg.singleNode.enableTLS then "https" else "http"}://${cfg.singleNode.hostname}";

          defaultText = lib.literalExpression ''
            ''${if cfg.singleNode.enableTLS then "https" else "http"}://''${config.${opt.singleNode.hostname}}
          '';

          description = ''
            URL of the host. If you are not using the automatic webserver proxy setup you will have
            to change this setting or your sync server may not be functional.
          '';

          type = lib.types.str;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.mysql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" = "all privileges";
          };

          name = cfg.database.user;
        }
      ];
    };

    services.nginx.virtualHosts = lib.mkIf cfg.singleNode.enableNginx {
      ${cfg.singleNode.hostname} = {
        enableACME = cfg.singleNode.enableTLS;
        forceSSL = cfg.singleNode.enableTLS;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.settings.port}";
          # We need to pass the Host header that matches the original Host header. Otherwise,
          # Hawk authentication will fail (because it assumes that the client and server see
          # the same value of the Host header).
          recommendedProxySettings = true;
        };
      };
    };

    systemd.services.firefox-syncserver = {
      after = lib.mkIf dbIsLocal [ "mysql.service" ];
      environment.RUST_LOG = cfg.logLevel;
      requires = lib.mkIf dbIsLocal [ "mysql.service" ];
      restartTriggers = lib.optional cfg.singleNode.enable setupScript;

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.secrets != null) "${cfg.secrets}";
        ExecStart = "${cfg.package}/bin/syncserver --config ${configFile}";
        Group = defaultUser;
        LockPersonality = true;
        # syncstorage-rs uses python-cffi internally, and python-cffi does not
        # work with MemoryDenyWriteExecute=true
        MemoryDenyWriteExecute = false;
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
        # hardening
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~ @privileged @resources"
        ];

        UMask = "0077";
        User = defaultUser;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.firefox-syncserver-setup = lib.mkIf cfg.singleNode.enable {
      after = [ "firefox-syncserver.service" ] ++ lib.optional dbIsLocal "mysql.service";
      path = [ config.services.mysql.package ];
      requires = [ "firefox-syncserver.service" ] ++ lib.optional dbIsLocal "mysql.service";
      serviceConfig.ExecStart = [ "${setupScript}" ];
      wantedBy = [ "firefox-syncserver.service" ];
    };
  };

  meta = {
    doc = ./firefox-syncserver.md;
    maintainers = [ ];
  };
}

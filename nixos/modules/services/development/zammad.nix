{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.zammad;
  settingsFormat = pkgs.formats.yaml { };
  filterNull = lib.filterAttrs (_: v: v != null);
  serviceConfig = {
    Group = cfg.group;
    PrivateTmp = true;
    Restart = "always";
    StateDirectory = "zammad";
    Type = "simple";
    User = cfg.user;
    WorkingDirectory = package;
  };
  environment = {
    NODE_ENV = "production";
    RAILS_ENV = "production";
    RAILS_LOG_TO_STDOUT = "true";
    RAILS_SERVE_STATIC_FILES = "true";
    REDIS_URL = "redis://${cfg.redis.host}:${toString cfg.redis.port}";
  };
  databaseConfig = settingsFormat.generate "database.yml" cfg.database.settings;
  package = cfg.package.override {
    dataDir = cfg.dataDir;
  };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "zammad"
      "openPorts"
    ] "The openPorts option was removed in favor of the nginx.configure option.")
  ];

  options = {
    services.zammad = {
      enable = lib.mkEnableOption "Zammad, a web-based, open source user support/ticketing solution";
      package = lib.mkPackageOption pkgs "zammad" { };

      dataDir = lib.mkOption {
        default = "/var/lib/zammad";

        description = ''
          Path to a folder that will contain Zammad working directory.
        '';

        type = lib.types.path;
      };

      database = {
        createLocally = lib.mkOption {
          default = true;
          description = "Whether to create a local database automatically.";
          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = "/run/postgresql";

          description = ''
            Database host address.
          '';

          type = lib.types.str;
        };

        name = lib.mkOption {
          default = "zammad";

          description = ''
            Database name.
          '';

          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            A file containing the password for {option}`services.zammad.database.user`.
          '';

          example = "/run/keys/zammad-dbpassword";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = null;
          description = "Database port. Use `null` for default port.";
          type = lib.types.nullOr lib.types.port;
        };

        settings = lib.mkOption {
          default = { };

          description = ''
            The {file}`database.yml` configuration file as key value set.
            See \<TODO\>
            for list of configuration parameters.
          '';

          example = lib.literalExpression ''
            {
            }
          '';

          type = settingsFormat.type;
        };

        user = lib.mkOption {
          default = "zammad";
          description = "Database user.";
          type = lib.types.nullOr lib.types.str;
        };
      };

      group = lib.mkOption {
        default = "zammad";

        description = ''
          Name of the Zammad group.
        '';

        type = lib.types.str;
      };

      host = lib.mkOption {
        default = "127.0.0.1";
        description = "Host address.";
        example = "192.168.23.42";
        type = lib.types.str;
      };

      nginx = {
        configure = lib.mkOption {
          default = false;
          description = "Whether to configure a local nginx for Zammad.";
          type = lib.types.bool;
        };

        domain = lib.mkOption {
          description = "The domain under which zammad will be reachable.";
          type = lib.types.str;
        };
      };

      port = lib.mkOption {
        default = 3000;
        description = "Web service port.";
        type = lib.types.port;
      };

      redis = {
        createLocally = lib.mkOption {
          default = true;
          description = "Whether to create a local redis automatically.";
          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = "localhost";

          description = ''
            Redis server address.
          '';

          type = lib.types.str;
        };

        name = lib.mkOption {
          default = "zammad";

          description = ''
            Name of the redis server. Only used if `createLocally` is set to true.
          '';

          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 6379;
          description = "Port of the redis server.";
          type = lib.types.port;
        };
      };

      secretKeyBaseFile = lib.mkOption {
        default = null;

        description = ''
          The path to a file containing the
          `secret_key_base` secret.

          Zammad uses `secret_key_base` to encrypt
          the cookie store, which contains session data, and to digest
          user auth tokens.

          Needs to be a 64 byte long string of hexadecimal
          characters. You can generate one by running

          ```
          openssl rand -hex 64 >/path/to/secret_key_base_file
          ```

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        example = "/run/keys/secret_key_base";
        type = lib.types.nullOr lib.types.path;
      };

      user = lib.mkOption {
        default = "zammad";

        description = ''
          Name of the Zammad user.
        '';

        type = lib.types.str;
      };

      websocketPort = lib.mkOption {
        default = 6042;
        description = "Websocket service port.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.database.createLocally -> cfg.database.user == "zammad" && cfg.database.name == "zammad";

        message = "services.zammad.database.user must be set to \"zammad\" if services.zammad.database.createLocally is set to true";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "a password cannot be specified if services.zammad.database.createLocally is set to true";
      }
      {
        assertion = cfg.redis.createLocally -> cfg.redis.host == "localhost";
        message = "the redis host must be localhost if services.zammad.redis.createLocally is set to true";
      }
    ];

    environment.systemPackages = [
      # we try to eumulate parts of the pkgr script that are relevant to NixOS
      (pkgs.writeShellScriptBin "zammad" ''
        if [[ ''${1:-} != run ]]; then
          echo "This script only supports the run subcommand".
          exit 1
        fi
        shift

        prog="$1"
        shift
        sudo -u ${cfg.user} -- env ${
          lib.concatMapAttrsStringSep " " (n: v: "${n}=${v}") environment
        } bash -c "cd ${cfg.package}; ${cfg.package}/bin/$prog $(printf " %q" "$@")"
      '')
    ];

    services = {
      nginx = lib.mkIf cfg.nginx.configure {
        enable = true;

        virtualHosts."${cfg.nginx.domain}" = {
          forceSSL = true;

          locations = {
            "/" = {
              extraConfig = # nginx
                ''
                  proxy_set_header CLIENT_IP $remote_addr;
                '';

              proxyPass = "http://127.0.0.1:${toString config.services.zammad.port}";
              recommendedProxySettings = true;
              root = "${config.services.zammad.package}/public/";
            };

            "/cable" = {
              extraConfig = # nginx
                ''
                  proxy_set_header CLIENT_IP $remote_addr;
                '';

              proxyPass = "http://127.0.0.1:${toString config.services.zammad.port}";
              proxyWebsockets = true;
            };

            "/ws" = {
              extraConfig = # nginx
                ''
                  proxy_set_header CLIENT_IP $remote_addr;
                '';

              proxyPass = "http://127.0.0.1:${toString config.services.zammad.websocketPort}";
              proxyWebsockets = true;
            };
          };
        };
      };

      postgresql = lib.optionalAttrs cfg.database.createLocally {
        enable = true;
        ensureDatabases = [ cfg.database.name ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = cfg.database.user;
          }
        ];
      };

      redis = lib.optionalAttrs cfg.redis.createLocally {
        servers."${cfg.redis.name}" = {
          enable = true;
          port = cfg.redis.port;
        };
      };
    };

    services.zammad.database.settings = {
      production = lib.mapAttrs (_: v: lib.mkDefault v) (filterNull {
        adapter = "postgresql";
        database = cfg.database.name;
        encoding = "utf8";
        host = cfg.database.host;
        pool = 50;
        port = cfg.database.port;
        timeout = 5000;
        username = cfg.database.user;
      });
    };

    systemd.services.zammad-web = {
      inherit environment;

      after = [
        "network.target"
        "systemd-tmpfiles-setup.service"
      ]
      ++ lib.optionals cfg.database.createLocally [
        "postgresql.target"
      ]
      ++ lib.optionals cfg.redis.createLocally [
        "redis-${cfg.redis.name}.service"
      ];

      description = "Zammad web";

      preStart = ''
        # config file
        cat ${databaseConfig} > ${cfg.dataDir}/config/database.yml
        ${lib.optionalString (cfg.database.passwordFile != null) ''
          {
            echo -n "  password: "
            cat ${cfg.database.passwordFile}
          } >> ${cfg.dataDir}/config/database.yml
        ''}
        ${lib.optionalString (cfg.secretKeyBaseFile != null) ''
          {
            echo "production: "
            echo -n "  secret_key_base: "
            cat ${cfg.secretKeyBaseFile}
          } > ${cfg.dataDir}/config/secrets.yml
        ''}

        # needed for cleanup
        shopt -s extglob

        # cleanup state directory from module before refactoring in
        # https://github.com/NixOS/nixpkgs/pull/277456
        if [[ -e ${cfg.dataDir}/node_modules ]]; then
          rm -rf ${cfg.dataDir}/!("tmp"|"config"|"log"|"state_dir_migrated"|"db_seeded"|"storage")
          rm -rf ${cfg.dataDir}/config/!("database.yml"|"secrets.yml")
          # state directory cleanup required --> zammad was already installed --> do not seed db
          echo true > ${cfg.dataDir}/db_seeded
        fi

        SEEDED=$(cat ${cfg.dataDir}/db_seeded)
        if [[ $SEEDED != "true" ]]; then
          echo "Initialize database"
          ./bin/rake --no-system db:migrate
          ./bin/rake --no-system db:seed
          echo true > ${cfg.dataDir}/db_seeded
        else
          echo "Migrate database"
          ./bin/rake --no-system db:migrate
        fi
        echo "Done"
      '';

      requires = lib.optionals cfg.database.createLocally [
        "postgresql.target"
      ];

      script = "./script/rails server -b ${cfg.host} -p ${toString cfg.port}";

      serviceConfig = serviceConfig // {
        # loading all the gems takes time
        TimeoutStartSec = 1200;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.zammad-websocket = {
      inherit serviceConfig environment;
      after = [ "zammad-web.service" ];
      description = "Zammad websocket";
      requires = [ "zammad-web.service" ];
      script = "./script/websocket-server.rb -b ${cfg.host} -p ${toString cfg.websocketPort} start";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.zammad-worker = {
      inherit serviceConfig environment;
      after = [ "zammad-web.service" ];
      description = "Zammad background worker";
      requires = [ "zammad-web.service" ];
      script = "./script/background-worker.rb start";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                               0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/config                        0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/log                           0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage                       0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/tmp                           0750 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/config/secrets.yml            0640 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/config/database.yml           0640 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/db_seeded                     0640 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      group = "${cfg.group}";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    taeer
    netali
    meenzen
  ];
}

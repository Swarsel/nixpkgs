{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let
  cfg = config.services.coder;
  name = "coder";
in
{
  options = {
    services.coder = {
      enable = mkEnableOption "Coder service";
      package = mkPackageOption pkgs "coder" { };

      accessUrl = mkOption {
        default = null;

        description = ''
          Access URL should be a external IP address or domain with DNS records pointing to Coder.
        '';

        example = "https://coder.example.com";
        type = types.nullOr types.str;
      };

      database = {
        createLocally = mkOption {
          default = true;

          description = ''
            Create the database and database user locally.
          '';

          type = types.bool;
        };

        database = mkOption {
          default = "coder";

          description = ''
            Name of database.
          '';

          type = types.str;
        };

        host = mkOption {
          default = "/run/postgresql";

          description = ''
            Hostname hosting the database.
          '';

          type = types.str;
        };

        password = mkOption {
          default = null;

          description = ''
            Password for accessing the database.
          '';

          type = types.nullOr types.str;
        };

        sslmode = mkOption {
          default = "disable";

          description = ''
            Password for accessing the database.
          '';

          type = types.nullOr types.str;
        };

        username = mkOption {
          default = "coder";

          description = ''
            Username for accessing the database.
          '';

          type = types.str;
        };
      };

      environment = {
        extra = mkOption {
          default = { };
          description = "Extra environment variables to pass run Coder's server with. See Coder documentation.";

          example = {
            CODER_OAUTH2_GITHUB_ALLOWED_ORGS = "your-org";
            CODER_OAUTH2_GITHUB_ALLOW_SIGNUPS = true;
          };

          type = types.attrs;
        };

        file = mkOption {
          default = null;
          description = "Systemd environment file to add to Coder.";
          type = types.nullOr types.path;
        };
      };

      group = mkOption {
        default = "coder";

        description = ''
          Group under which the coder service runs.

          ::: {.note}
          If left as the default value this group will automatically be created
          on system activation, otherwise it needs to be configured manually.
          :::
        '';

        type = types.str;
      };

      homeDir = mkOption {
        default = "/var/lib/coder";

        description = ''
          Home directory for coder user.
        '';

        type = types.str;
      };

      listenAddress = mkOption {
        default = "127.0.0.1:3000";

        description = ''
          Listen address.
        '';

        type = types.str;
      };

      tlsCert = mkOption {
        default = null;

        description = ''
          The path to the TLS certificate.
        '';

        type = types.nullOr types.path;
      };

      tlsKey = mkOption {
        default = null;

        description = ''
          The path to the TLS key.
        '';

        type = types.nullOr types.path;
      };

      user = mkOption {
        default = "coder";

        description = ''
          User under which the coder service runs.

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise it needs to be configured manually.
          :::
        '';

        type = types.str;
      };

      wildcardAccessUrl = mkOption {
        default = null;

        description = ''
          If you are providing TLS certificates directly to the Coder server, you must use a single certificate for the root and wildcard domains.
        '';

        example = "*.coder.example.com";
        type = types.nullOr types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.database.createLocally
          -> cfg.database.username == name && cfg.database.database == cfg.database.username;

        message = "services.coder.database.username must be set to ${name} if services.coder.database.createLocally is set true";
      }
    ];

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;

      ensureDatabases = [
        cfg.database.database
      ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.user;
        }
      ];
    };

    systemd.services.coder = {
      after = [ "network.target" ];
      description = "Coder - Self-hosted developer workspaces on your infra";

      environment = cfg.environment.extra // {
        CODER_ACCESS_URL = cfg.accessUrl;
        CODER_ADDRESS = cfg.listenAddress;

        CODER_PG_CONNECTION_URL = "user=${cfg.database.username} ${
          optionalString (cfg.database.password != null) "password=${cfg.database.password}"
        } database=${cfg.database.database} host=${cfg.database.host} ${
          optionalString (cfg.database.sslmode != null) "sslmode=${cfg.database.sslmode}"
        }";

        CODER_TLS_CERT_FILE = cfg.tlsCert;
        CODER_TLS_ENABLE = optionalString (cfg.tlsCert != null) "1";
        CODER_TLS_KEY_FILE = cfg.tlsKey;
        CODER_WILDCARD_ACCESS_URL = cfg.wildcardAccessUrl;
      };

      serviceConfig = {
        AmbientCapabilities = "CAP_IPC_LOCK CAP_NET_BIND_SERVICE";
        CacheDirectory = "coder";
        CapabilityBoundingSet = "CAP_SYSLOG CAP_IPC_LOCK CAP_NET_BIND_SERVICE";
        EnvironmentFile = lib.mkIf (cfg.environment.file != null) cfg.environment.file;
        ExecStart = "${cfg.package}/bin/coder server";
        Group = cfg.group;
        KillMode = "mixed";
        KillSignal = "SIGINT";
        NoNewPrivileges = "yes";
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        ProtectSystem = "full";
        Restart = "on-failure";
        SecureBits = "keep-caps";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = optionalAttrs (cfg.group == name) {
      "${cfg.group}" = { };
    };

    users.users = optionalAttrs (cfg.user == name) {
      ${name} = {
        createHome = true;
        description = "Coder service user";
        group = cfg.group;
        home = cfg.homeDir;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = pkgs.coder.meta.maintainers;
}

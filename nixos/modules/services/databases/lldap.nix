{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lldap;
  format = pkgs.formats.toml { };
  dbName = "lldap";
  dbUser = "lldap";
  localPostgresql = cfg.database.createLocally && cfg.database.type == "postgresql";
  localMysql = cfg.database.createLocally && cfg.database.type == "mariadb";
in
{
  options.services.lldap = with lib; {
    enable = mkEnableOption "lldap, a lightweight authentication server that provides an opinionated, simplified LDAP interface for authentication";
    package = mkPackageOption pkgs "lldap" { };

    database = {
      createLocally = mkOption {
        default = true;
        description = "Create the database and database user locally.";
        type = types.bool;
      };

      type = mkOption {
        default = "sqlite";
        description = "Database engine to use.";
        example = "postgresql";

        type = types.enum [
          "mariadb"
          "postgresql"
          "sqlite"
        ];
      };
    };

    environment = mkOption {
      default = { };

      description = ''
        Environment variables passed to the service.
        Any config option name prefixed with `LLDAP_` takes priority over the one in the configuration file.
      '';

      example = {
        LLDAP_JWT_SECRET_FILE = "/run/lldap/jwt_secret";
        LLDAP_LDAP_USER_PASS_FILE = "/run/lldap/user_password";
      };

      type = with types; attrsOf str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)` passed to the service.
      '';

      type = types.nullOr types.path;
    };

    settings = mkOption {
      # TOML does not allow null values, so we use null to omit those fields
      apply = lib.filterAttrsRecursive (_: v: v != null);
      default = { };

      description = ''
        Free-form settings written directly to the {file}`lldap_config.toml` file.
        Refer to <https://github.com/lldap/lldap/blob/main/lldap_config.docker_template.toml> for supported values.
      '';

      type = types.submodule {
        options = {
          database_url = mkOption {
            default = null;

            defaultText = lib.literalExpression ''
              if config.services.lldap.database.createLocally
              then
                if cfg.database.type == "sqlite"
                then "sqlite://./users.db?mode=rwc"
                else if cfg.database.type == "postgresql"
                then "postgresql:///lldap?host=/run/postgresql"
                else if cfg.database.type == "mariadb"
                then "mysql://lldap@localhost/lldap?socket=/run/mysqld/mysqld.sock"
              else null
            '';

            description = "Database URL.";
            example = "postgres://postgres-user:password@postgres-server/my-database";
            type = types.nullOr types.str;
          };

          force_ldap_user_pass_reset = mkOption {
            default = false;

            description = ''
              Force reset of the admin password.

              Set this setting to `"always"` to update the admin password when `ldap_user_pass_file` changes.
              Setting to `"always"` also means any password update in the UI will be overwritten next time the service restarts.

              The difference between `true` and `"always"` is the former is intended for a one time fix
              while the latter is intended for a declarative workflow. In practice, the result
              is the same: the password gets reset. The only practical difference is the former
              outputs a warning message while the latter outputs an info message.
            '';

            type = types.oneOf [
              types.bool
              (types.enum [ "always" ])
            ];
          };

          http_host = mkOption {
            default = "::";
            description = "The host address that the HTTP server will be bound to.";
            type = types.str;
          };

          http_port = mkOption {
            default = 17170;
            description = "The port on which to have the HTTP server, for user login and administration.";
            type = types.port;
          };

          http_url = mkOption {
            default = "http://localhost";
            description = "The public URL of the server, for password reset links.";
            type = types.str;
          };

          jwt_secret_file = mkOption {
            default = null;

            description = ''
              Path to a file containing the JWT secret.
            '';

            type = types.nullOr types.str;
          };

          ldap_base_dn = mkOption {
            description = "Base DN for LDAP.";
            example = "dc=example,dc=com";
            type = types.str;
          };

          ldap_host = mkOption {
            default = "::";
            description = "The host address that the LDAP server will be bound to.";
            type = types.str;
          };

          ldap_port = mkOption {
            default = 3890;
            description = "The port on which to have the LDAP server.";
            type = types.port;
          };

          ldap_user_dn = mkOption {
            default = "admin";
            description = "Admin username";
            type = types.str;
          };

          ldap_user_email = mkOption {
            default = "admin@example.com";
            description = "Admin email.";
            type = types.str;
          };

          ldap_user_pass = mkOption {
            default = null;

            description = ''
              Password for default admin password.

              Unsecure: Use `ldap_user_pass_file` settings instead.
            '';

            type = types.nullOr types.str;
          };

          ldap_user_pass_file = mkOption {
            default = null;

            description = ''
              Path to a file containing the default admin password.

              If you want to update the default admin password through this setting,
              you must set `force_ldap_user_pass_reset` to `true`.
              Otherwise changing this setting will have no effect
              unless this is the very first time LLDAP is started and its database is still empty.
            '';

            type = types.nullOr types.str;
          };
        };

        freeformType = format.type;
      };
    };

    silenceForceUserPassResetWarning = mkOption {
      default = false;

      description = ''
        Disable warning when the admin password is set declaratively with the `ldap_user_pass_file` setting
        but the `force_ldap_user_pass_reset` is set to `false`.

        This can lead to the admin password to drift from the one given declaratively.
        If that is okay for you and you want to silence the warning, set this option to `true`.
      '';

      type = types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          (cfg.settings.ldap_user_pass_file or null) != null
          || (cfg.settings.ldap_user_pass or null) != null
          || (cfg.environment.LLDAP_LDAP_USER_PASS_FILE or null) != null;

        message = "lldap: Default admin user password must be set. Please set the `ldap_user_pass` or better the `ldap_user_pass_file` setting. Alternatively, you can set the `LLDAP_LDAP_USER_PASS_FILE` environment variable.";
      }
      {
        assertion =
          (cfg.settings.ldap_user_pass_file or null) == null || (cfg.settings.ldap_user_pass or null) == null;

        message = "lldap: Both `ldap_user_pass` and `ldap_user_pass_file` settings should not be set at the same time. Set one to `null`.";
      }
    ];

    services.lldap.settings.database_url = lib.mkIf cfg.database.createLocally (
      lib.mkDefault (
        if cfg.database.type == "sqlite" then
          "sqlite://./users.db?mode=rwc"
        else if cfg.database.type == "postgresql" then
          "postgresql:///${dbName}?host=/run/postgresql"
        else if cfg.database.type == "mariadb" then
          "mysql://${dbUser}@localhost/${dbName}?socket=/run/mysqld/mysqld.sock"
        else
          null
      )
    );

    services.mysql = lib.mkIf localMysql {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
      ensureDatabases = [ dbName ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${dbName}.*" = "ALL PRIVILEGES";
          };

          name = dbUser;
        }
      ];
    };

    services.postgresql = lib.mkIf localPostgresql {
      enable = true;
      ensureDatabases = [ dbName ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = dbUser;
        }
      ];
    };

    systemd.services.lldap = {
      inherit (cfg) environment;

      after = [
        "network-online.target"
      ]
      ++ lib.optional localPostgresql "postgresql.target"
      ++ lib.optional localMysql "mysql.service";

      description = "Lightweight LDAP server (lldap)";

      requires =
        lib.optional localPostgresql "postgresql.target" ++ lib.optional localMysql "mysql.service";

      # lldap defaults to a hardcoded `jwt_secret` value if none is provided, which is bad, because
      # an attacker could create a valid admin jwt access token fairly trivially.
      # Because there are 3 different ways `jwt_secret` can be provided, we check if any one of them is present,
      # and if not, bootstrap a secret in `/var/lib/lldap/jwt_secret_file` and give that to lldap.
      script =
        lib.optionalString (!cfg.settings ? jwt_secret) ''
          if [[ -z "$LLDAP_JWT_SECRET_FILE" ]] && [[ -z "$LLDAP_JWT_SECRET" ]]; then
            if [[ ! -e "./jwt_secret_file" ]]; then
              ${lib.getExe pkgs.openssl} rand -base64 -out ./jwt_secret_file 32
            fi
            export LLDAP_JWT_SECRET_FILE="./jwt_secret_file"
          fi
        ''
        + ''
          exec ${lib.getExe cfg.package} run --config-file ${format.generate "lldap_config.toml" cfg.settings}
        '';

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        Group = "lldap";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "lldap";
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0027";
        User = "lldap";
        WorkingDirectory = "%S/lldap";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    warnings =
      lib.optionals ((cfg.settings.ldap_user_pass or null) != null) [
        ''
          lldap: Unsecure `ldap_user_pass` setting is used. Prefer `ldap_user_pass_file` instead.
        ''
      ]
      ++
        lib.optionals
          (cfg.settings.force_ldap_user_pass_reset == false && cfg.silenceForceUserPassResetWarning == false)
          [
            ''
              lldap: The `force_ldap_user_pass_reset` setting is set to `false` which means
              the admin password can be changed through the UI and will drift from the one defined in your nix config.
              It also means changing the setting `ldap_user_pass` or `ldap_user_pass_file` will have no effect on the admin password.
              Either set `force_ldap_user_pass_reset` to `"always"` or silence this warning by setting the option `services.lldap.silenceForceUserPassResetWarning` to `true`.
            ''
          ];
  };
}

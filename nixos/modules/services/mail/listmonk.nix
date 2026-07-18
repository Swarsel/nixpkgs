{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.listmonk;
  tomlFormat = pkgs.formats.toml { };
  cfgFile = tomlFormat.generate "listmonk.toml" cfg.settings;
  # Escaping is done according to https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS
  setDatabaseOption =
    key: value:
    "UPDATE settings SET value = '${
      lib.replaceStrings [ "'" ] [ "''" ] (builtins.toJSON value)
    }' WHERE key = '${key}';";
  updateDatabaseConfigSQL = pkgs.writeText "update-database-config.sql" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList setDatabaseOption (
        if (cfg.database.settings != null) then cfg.database.settings else { }
      )
    )
  );
  updateDatabaseConfigScript = pkgs.writeShellScriptBin "update-database-config.sh" ''
    ${
      if cfg.database.mutableSettings then
        ''
          if [ ! -f /var/lib/listmonk/.db_settings_initialized ]; then
            ${pkgs.postgresql}/bin/psql -d listmonk -f ${updateDatabaseConfigSQL} ;
            touch /var/lib/listmonk/.db_settings_initialized
          fi
        ''
      else
        "${pkgs.postgresql}/bin/psql -d listmonk -f ${updateDatabaseConfigSQL}"
    }
  '';

  databaseSettingsOpts = with lib.types; {
    options = {
      "app.notify_emails" = lib.mkOption {
        default = [ ];
        description = "Administrator emails for system notifications";
        type = listOf str;
      };

      # TODO: refine this type based on the smtp one.
      "bounce.mailboxes" = lib.mkOption {
        default = [ ];
        description = "List of bounce mailboxes";

        type = listOf (submodule {
          freeformType = with lib.types; listOf (attrsOf anything);
        });
      };

      messengers = lib.mkOption {
        default = [ ];
        description = "List of messengers, see: <https://github.com/knadh/listmonk/blob/master/models/settings.go#L64-L74> for options.";
        type = listOf str;
      };

      "privacy.domain_blocklist" = lib.mkOption {
        default = [ ];
        description = "E-mail addresses with these domains are disallowed from subscribing.";
        type = listOf str;
      };

      "privacy.exportable" = lib.mkOption {
        default = [
          "profile"
          "subscriptions"
          "campaign_views"
          "link_clicks"
        ];

        description = "List of fields which can be exported through an automatic export request";
        type = listOf str;
      };

      smtp = lib.mkOption {
        description = "List of outgoing SMTP servers";

        type = listOf (submodule {
          options = {
            enabled = lib.mkEnableOption "this SMTP server for listmonk";

            host = lib.mkOption {
              description = "Hostname for the SMTP server";
              type = lib.types.str;
            };

            max_conns = lib.mkOption {
              default = 1;
              description = "Maximum number of simultaneous connections, defaults to 1";
              type = lib.types.int;
            };

            port = lib.mkOption {
              description = "Port for the SMTP server";
              type = lib.types.port;
            };

            tls_type = lib.mkOption {
              description = "Type of TLS authentication with the SMTP server";

              type = lib.types.enum [
                "none"
                "STARTTLS"
                "TLS"
              ];
            };
          };

          freeformType = with lib.types; attrsOf anything;
        });
      };
    };

    freeformType = attrsOf (oneOf [
      (listOf str)
      (listOf (attrsOf anything))
      str
      int
      bool
    ]);
  };
in
{
  ###### interface
  options = {
    services.listmonk = {
      enable = lib.mkEnableOption "Listmonk, this module assumes a reverse proxy to be set";
      package = lib.mkPackageOption pkgs "listmonk" { };

      database = {
        createLocally = lib.mkOption {
          default = false;
          description = "Create the PostgreSQL database and database user locally.";
          type = lib.types.bool;
        };

        mutableSettings = lib.mkOption {
          default = true;

          description = ''
            Database settings will be reset to the value set in this module if this is not enabled.
            Enable this if you want to persist changes you have done in the application.
          '';

          type = lib.types.bool;
        };

        settings = lib.mkOption {
          default = null;
          description = "Dynamic settings in the PostgreSQL database, set by a SQL script, see <https://github.com/knadh/listmonk/blob/master/schema.sql#L177-L230> for details.";
          type = with lib.types; nullOr (submodule databaseSettingsOpts);
        };
      };

      secretFile = lib.mkOption {
        default = null;
        description = "A file containing secrets as environment variables. See <https://listmonk.app/docs/configuration/#environment-variables> for details on supported values.";
        type = lib.types.nullOr lib.types.str;
      };

      settings = lib.mkOption {
        description = ''
          Static settings set in the config.toml, see <https://github.com/knadh/listmonk/blob/master/config.toml.sample> for details.
          You can set secrets using the secretFile option with environment variables following <https://listmonk.app/docs/configuration/#environment-variables>.
        '';

        type = lib.types.submodule { freeformType = tomlFormat.type; };
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    # Default parameters from https://github.com/knadh/listmonk/blob/master/config.toml.sample
    services.listmonk.settings."app".address = lib.mkDefault "localhost:9000";

    services.listmonk.settings."db" = lib.mkMerge [
      {
        max_idle = lib.mkDefault 25;
        max_lifetime = lib.mkDefault "300s";
        max_open = lib.mkDefault 25;
      }
      (lib.mkIf cfg.database.createLocally {
        database = lib.mkDefault "listmonk";
        host = lib.mkDefault "/run/postgresql";
        port = lib.mkDefault 5432;
        user = lib.mkDefault "listmonk";
      })
    ];

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "listmonk" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "listmonk";
        }
      ];
    };

    systemd.services.listmonk = {
      after = [ "network.target" ] ++ lib.optional cfg.database.createLocally "postgresql.target";
      description = "Listmonk - newsletter and mailing list manager";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.secretFile != null) [ cfg.secretFile ];
        ExecStart = "${cfg.package}/bin/listmonk --config ${cfgFile}";

        ExecStartPre = [
          # StateDirectory cannot be used when DynamicUser = true is set this way.
          # Indeed, it will try to create all the folders and realize one of them already exist.
          # Therefore, we have to create it ourselves.
          ''${pkgs.coreutils}/bin/mkdir -p "''${STATE_DIRECTORY}/listmonk/uploads"''
          # setup database if not already done
          "${cfg.package}/bin/listmonk --config ${cfgFile} --idempotent --install --yes"
          # apply db migrations (setup and migrations can not be done in one step
          # with "--install --upgrade" listmonk ignores the upgrade)
          "${cfg.package}/bin/listmonk --config ${cfgFile} --upgrade --yes"
          "${updateDatabaseConfigScript}/bin/update-database-config.sh"
        ];

        Group = "listmonk";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = [ "listmonk" ];
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        Type = "exec";
        UMask = "0027";
        User = "listmonk";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

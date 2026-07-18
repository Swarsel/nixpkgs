{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    literalExpression
    mkIf
    ;
  cfg = config.services.miniflux;

  boolToInt = b: if b then 1 else 0;

  pgbin = "${config.services.postgresql.package}/bin";
  # The hstore extension is no longer needed as of v2.2.14
  # and would prevent Miniflux from starting.
  preStart = pkgs.writeScript "miniflux-pre-start" ''
    #!${pkgs.runtimeShell}
    ${pgbin}/psql "miniflux" -c "DROP EXTENSION IF EXISTS hstore"
  '';
in

{
  options = {
    services.miniflux = {
      config = mkOption {
        default = { };

        description = ''
          Configuration for Miniflux, refer to
          <https://miniflux.app/docs/configuration.html>
          for documentation on the supported values.
        '';

        type = types.submodule {
          options = {
            CREATE_ADMIN = mkOption {
              default = true;
              description = "Create an admin user from environment variables.";
              type = with types; coercedTo bool boolToInt int;
            };

            DATABASE_URL = mkOption {
              default =
                if cfg.createDatabaseLocally then "user=miniflux host=/run/postgresql dbname=miniflux" else null;

              defaultText = literalExpression ''
                if createDatabaseLocally then "user=miniflux host=/run/postgresql dbname=miniflux" else null
              '';

              description = ''
                Postgresql connection parameters.
                See [lib/pq](https://pkg.go.dev/github.com/lib/pq#hdr-Connection_String_Parameters) for more details.
              '';

              type = types.nullOr types.str;
            };

            LISTEN_ADDR = mkOption {
              default = "localhost:8080";

              description = ''
                Address to listen on. Use absolute path for a Unix socket.
                Multiple addresses can be specified, separated by commas.
              '';

              example = "127.0.0.1:8080, 127.0.0.1:8081";
              type = types.str;
            };

            RUN_MIGRATIONS = mkOption {
              default = true;
              description = "Run database migrations.";
              type = with types; coercedTo bool boolToInt int;
            };

            WATCHDOG = mkOption {
              default = true;
              description = "Enable or disable Systemd watchdog.";
              type = with types; coercedTo bool boolToInt int;
            };
          };

          freeformType =
            with types;
            attrsOf (oneOf [
              str
              int
            ]);
        };
      };

      enable = mkEnableOption "miniflux";
      package = mkPackageOption pkgs "miniflux" { };

      adminCredentialsFile = mkOption {
        default = null;

        description = ''
          File containing the ADMIN_USERNAME and
          ADMIN_PASSWORD (length >= 6) in the format of
          an EnvironmentFile=, as described by {manpage}`systemd.exec(5)`.
        '';

        example = "/etc/nixos/miniflux-admin-credentials";
        type = types.nullOr types.path;
      };

      createDatabaseLocally = mkOption {
        default = true;

        description = ''
          Whether a PostgreSQL database should be automatically created and
          configured on the local host. If set to `false`, you need provision a
          database yourself.
        '';

        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.config.CREATE_ADMIN == 0 || cfg.adminCredentialsFile != null;
        message = "services.miniflux.adminCredentialsFile must be set if services.miniflux.config.CREATE_ADMIN is 1";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    security.apparmor.policies."bin.miniflux".profile = ''
      abi <abi/4.0>,
      include <tunables/global>

      profile ${cfg.package}/bin/miniflux {
        include <abstractions/base>
        include <abstractions/nameservice>
        include <abstractions/ssl_certs>
        include <abstractions/golang>
        include "${pkgs.apparmorRulesFromClosure { name = "miniflux"; } cfg.package}"
        ${cfg.package}/bin/miniflux r,
        /run/miniflux/** rw,
        include if exists <local/bin.miniflux>
      }
    '';

    services.postgresql = lib.mkIf cfg.createDatabaseLocally {
      enable = true;
      ensureDatabases = [ "miniflux" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "miniflux";
        }
      ];
    };

    systemd.services.miniflux = {
      after = [
        "network.target"
      ]
      ++ lib.optionals cfg.createDatabaseLocally [
        "postgresql.target"
        "miniflux-dbsetup.service"
      ];

      description = "Miniflux service";
      environment = lib.mapAttrs (_: toString) (lib.filterAttrs (_: v: v != null) cfg.config);

      requires = lib.optionals cfg.createDatabaseLocally [
        "miniflux-dbsetup.service"
        "postgresql.target"
      ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.adminCredentialsFile != null) cfg.adminCredentialsFile;
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
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
        Restart = "always";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "miniflux";
        RuntimeDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        Type = "notify";
        UMask = "0077";
        User = "miniflux";
        WatchdogSec = 60;
        WatchdogSignal = "SIGKILL";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.miniflux-dbsetup = lib.mkIf cfg.createDatabaseLocally {
      after = [
        "network.target"
        "postgresql.target"
      ];

      description = "Miniflux database setup";
      requires = [ "postgresql.target" ];

      serviceConfig = {
        ExecStart = preStart;
        Type = "oneshot";
        User = config.services.postgresql.superUser;
      };
    };
  };
}

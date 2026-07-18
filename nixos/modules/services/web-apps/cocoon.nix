{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cocoon;

  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    optional
    ;
in
{
  options.services.cocoon = {
    enable = mkEnableOption "cocoon";
    package = mkPackageOption pkgs "cocoon" { };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.

        Use it to set values of `COCOON_ADMIN_PASSWORD` and `COCOON_SESSION_SECRE`.

        Generate `COCOON_ADMIN_PASSWORD` with
        ```
        openssl rand -hex 16
        ```

        Generate `COCOON_SESSION_SECRET` with
        ```
        openssl rand -hex 32
        ```
      '';

      type = types.listOf types.path;
    };

    settings = mkOption {
      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to <https://github.com/haileyok/cocoon/blob/main/.env.example>
        and <https://github.com/haileyok/cocoon/blob/main/README.md> for
        available environment variables.
      '';

      type = types.submodule {
        options = {
          COCOON_ADDR = mkOption {
            default = ":8080";
            description = "Address to bind the Cocoon instance to";
            example = ":3000";
            type = types.str;
          };

          COCOON_CONTACT_EMAIL = mkOption {
            description = "Contact email for the Cocoon instance";
            example = "me@example.com";
            type = types.str;
          };

          COCOON_DATABASE_URL = mkOption {
            default = null;
            description = "Database connection URL";
            example = "postgres://cocoon:password@localhost:5432/cocoon?sslmode=disable";
            type = types.nullOr types.str;
          };

          COCOON_DB_NAME = mkOption {
            default = "/var/lib/cocoon/cocoon.db";
            description = "Name of the SQLite database file (if using sqlite)";
            type = types.str;
          };

          COCOON_DB_TYPE = mkOption {
            default = "sqlite";
            description = "Type of database to use (sqlite or postgres)";
            type = types.str;
          };

          COCOON_DID = mkOption {
            description = "DID web address for the Cocoon instance";
            example = "did:web:cocoon.example.com";
            type = types.nullOr types.str;
          };

          COCOON_HOSTNAME = mkOption {
            description = "Hostname for the Cocoon instance";
            example = "cocoon.example.com";
            type = types.nullOr types.str;
          };

          COCOON_JWK_PATH = mkOption {
            default = "/var/lib/cocoon/jwk.key";

            description = ''
              Path to the JWK key file

              Generate it with:
              ```
              cocoon create-private-jwk --out /var/lib/cocoon/jwk.key
              ```
            '';

            type = types.either types.path types.str;
          };

          COCOON_RELAYS = mkOption {
            default = "https://bsky.network";
            description = "Comma-separated list of Nostr relays to connect to";
            type = types.str;
          };

          COCOON_ROTATION_KEY_PATH = mkOption {
            default = "/var/lib/cocoon/rotation.key";

            description = ''
              Path to the rotation key file.

              Generate it with:
              ```
              cocoon create-rotation-key --out /var/lib/cocoon/rotation.key
              ```
            '';

            type = types.either types.path types.str;
          };

          COCOON_SESSION_COOKIE_KEY = mkOption {
            default = "session";
            description = "Name of the session cookie";
            type = types.str;
          };
        };

        freeformType = types.attrsOf (types.nullOr (types.either types.str types.path));
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.cocoon = {
      after = [
        "network-online.target"
      ]
      ++ optional (cfg.settings.COCOON_DB_TYPE == "postgres") "postgresql.service";

      description = "cocoon";

      serviceConfig = {
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DeviceAllow = [ "" ];

        Environment = lib.mapAttrsToList (k: v: "${k}=${if builtins.isInt v then toString v else v}") (
          lib.filterAttrs (_: v: v != null) cfg.settings
        );

        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${getExe cfg.package} run";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        # Hardening
        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "cocoon";
        StateDirectoryMode = "0755";
        SystemCallArchitectures = [ "native" ];
        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
      ]
      ++ optional (cfg.settings.COCOON_DB_TYPE == "postgres") "postgresql.service";
    };
  };

  meta.maintainers = with lib.maintainers; [ isabelroses ];
}

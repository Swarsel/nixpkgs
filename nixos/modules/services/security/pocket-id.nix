{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatMap
    concatStringsSep
    getExe
    maintainers
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    optionalAttrs
    ;
  inherit (lib.types)
    attrsOf
    bool
    path
    str
    submodule
    ;

  cfg = config.services.pocket-id;

  format = pkgs.formats.keyValue { };
  settingsFile = format.generate "pocket-id-env-vars" cfg.settings;

  exportCredentials = n: _: ''export ${n}="$(${pkgs.systemd}/bin/systemd-creds cat ${n}_FILE)"'';
  exportAllCredentials = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList exportCredentials vars);
  getLoadCredentialList = lib.mapAttrsToList (n: v: "${n}_FILE:${v}") cfg.credentials;
in
{
  options.services.pocket-id = {
    enable = mkEnableOption "Pocket ID server";
    package = mkPackageOption pkgs "pocket-id" { };

    credentials = mkOption {
      default = { };

      description = ''
        Credentials which are loaded from the contents of the specified file paths.

        This can be used to securely store tokens and secrets outside of the world-readable Nix store.

        See [PocketID environment variables](https://pocket-id.org/docs/configuration/environment-variables) (all with the `_FILE` suffix).

        Accepts an attrset mapping from the variable name *without its `_FILE` suffix* to the path on disk.

        Alternatively you can use `services.pocket-id.environmentFile` to define all the variables in a single file.
      '';

      example = {
        ENCRYPTION_KEY = "/run/secrets/pocket-id/encryption-key";
      };

      type = attrsOf path;
    };

    dataDir = mkOption {
      default = "/var/lib/pocket-id";

      description = ''
        The directory where Pocket ID will store its data, such as the database when using SQLite.
      '';

      type = path;
    };

    environmentFile = mkOption {
      default = "/dev/null";

      description = ''
        Path to an environment file to be loaded.
        This can be used to securely store tokens and secrets outside of the world-readable Nix store.

        See [PocketID environment variables](https://pocket-id.org/docs/configuration/environment-variables).

        Example contents of the file:
        MAXMIND_LICENSE_KEY=your-license-key

        Alternatively you can use `services.pocket-id.credentials` to define each variable in separate files.
      '';

      example = "/var/lib/secrets/pocket-id";
      type = path;
    };

    group = mkOption {
      default = "pocket-id";
      description = "Group account under which Pocket ID runs.";
      type = str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Environment variables to be passed.

        See [PocketID environment variables](https://pocket-id.org/docs/configuration/environment-variables).
      '';

      type = submodule {
        options = {
          ANALYTICS_DISABLED = mkOption {
            default = false;

            description = ''
              Whether to disable analytics.

              See the [analytics documentation](https://pocket-id.org/docs/configuration/analytics/).
            '';

            type = bool;
          };

          APP_URL = mkOption {
            default = "http://localhost";

            description = ''
              The URL where you will access the app.
            '';

            type = str;
          };

          TRUST_PROXY = mkOption {
            default = false;

            description = ''
              Whether the app is behind a reverse proxy.
            '';

            type = bool;
          };
        };

        freeformType = format.type;
      };
    };

    user = mkOption {
      default = "pocket-id";
      description = "User account under which Pocket ID runs.";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    assertions = (
      map
        (
          # Converted to assert 2026-01-08
          setting: {
            assertion = !(cfg.settings ? "${setting}");

            message = ''
              `services.pocket-id.settings.${setting}` is deprecated.
              See [v1 migration guide](https://pocket-id.org/docs/setup/major-releases/migrate-v1).
            '';
          })
        [
          "PUBLIC_APP_URL"
          "PUBLIC_UI_CONFIG_DISABLED"
          "CADDY_DISABLED"
          "CADDY_PORT"
          "BACKEND_PORT"
          "POSTGRES_CONNECTION_STRING"
          "SQLITE_DB_PATH"
          "INTERNAL_BACKEND_URL"
        ]
    );

    systemd.services = {
      pocket-id = {
        after = [ "network.target" ];
        description = "Pocket ID";

        restartTriggers = [
          cfg.package
          cfg.environmentFile
          settingsFile
        ];

        script = ''
          ${exportAllCredentials cfg.credentials}
          exec ${getExe cfg.package}
        '';

        serviceConfig = {
          # Hardening
          AmbientCapabilities = "";
          CapabilityBoundingSet = "";
          DeviceAllow = "";
          DevicePolicy = "closed";

          EnvironmentFile = [
            cfg.environmentFile
            settingsFile
          ];

          Group = cfg.group;
          LoadCredential = getLoadCredentialList;
          #IPAddressDeny = "any"; # provides the service through network
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateNetwork = false; # provides the service through network
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
          ReadWritePaths = [ cfg.dataDir ];
          RemoveIPC = true;
          Restart = "always";
          RestartSec = 1;

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = concatStringsSep " " [
            "~"
            "@clock"
            "@cpu-emulation"
            "@debug"
            "@module"
            "@mount"
            "@obsolete"
            "@privileged"
            "@raw-io"
            "@reboot"
            "@resources"
            "@swap"
          ];

          Type = "simple";
          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group}"
    ];

    users.groups = optionalAttrs (cfg.group == "pocket-id") {
      pocket-id = { };
    };

    users.users = optionalAttrs (cfg.user == "pocket-id") {
      pocket-id = {
        description = "Pocket ID backend user";
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

    warnings =
      (concatMap
        (
          setting:
          optional (cfg.settings ? "${setting}") ''
            `services.pocket-id.settings.${setting}` will be stored as plaintext in the Nix store. Use `services.pocket-id.credentials.${setting}` or `services.pocket-id.environmentFile` instead.
          ''
        )
        [
          "ENCRYPTION_KEY"
          "MAXMIND_LICENSE_KEY"
          "SMTP_PASSWORD"
          "LDAP_BIND_PASSWORD"
        ]
      )
      ++ (concatMap
        (
          # Added 2026-01-08
          setting:
          optional (cfg.settings ? "${setting}") ''
            `services.pocket-id.settings.${setting}` is deprecated.
            See [v2 migration guide](https://pocket-id.org/docs/setup/major-releases/migrate-v2).
          ''
        )
        [
          "DB_PROVIDER"
          "KEYS_PATH"
          "KEYS_STORAGE"
          "LDAP_ATTRIBUTE_ADMIN_GROUP"
        ]
      );
  };

  meta.maintainers = with maintainers; [
    gepbird
    ymstnt
  ];
}

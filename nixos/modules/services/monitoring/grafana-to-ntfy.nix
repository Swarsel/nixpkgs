{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.grafana-to-ntfy;
in
{
  options = {
    services.grafana-to-ntfy = {
      enable = lib.mkEnableOption "grafana-to-ntfy, a Grafana/Alertmanager to ntfy.sh bridge";
      package = lib.mkPackageOption pkgs "grafana-to-ntfy" { };

      settings = {
        address = lib.mkOption {
          default = "127.0.0.1";
          description = "Address to listen on.";
          example = "0.0.0.0";
          type = lib.types.str;
        };

        bauthPass = lib.mkOption {
          default = null;

          description = ''
            Path to the password file for Basic Auth on incoming webhook requests.
            When set together with {option}`bauthUser`, incoming requests require Basic Auth.
            When both are null, the endpoint is open (unauthenticated).
          '';

          example = "/run/secrets/grafana-to-ntfy-bauth-pass";
          type = lib.types.nullOr lib.types.path;
        };

        bauthUser = lib.mkOption {
          default = null;

          description = ''
            The user for Basic Auth on incoming webhook requests from Grafana or Alertmanager.
            When set together with {option}`bauthPass`, incoming requests require Basic Auth.
            When both are null, the endpoint is open (unauthenticated).
          '';

          example = "admin";
          type = lib.types.nullOr lib.types.str;
        };

        markdown = lib.mkOption {
          default = false;
          description = "Enable Markdown formatting in ntfy notifications. Sets the X-Markdown header.";
          type = lib.types.bool;
        };

        ntfyBAuthPass = lib.mkOption {
          default = null;

          description = ''
            The path to the password for the specified ntfy-sh user.
            Setting this option is required when using a ntfy-sh instance with access control enabled.
          '';

          example = "/run/secrets/grafana-to-ntfy-ntfy-pass";
          type = lib.types.nullOr lib.types.path;
        };

        ntfyBAuthUser = lib.mkOption {
          default = null;

          description = ''
            The ntfy-sh user to use for authenticating with the ntfy-sh instance.
            Setting this option is required when using a ntfy-sh instance with access control enabled.
          '';

          example = "grafana";
          type = lib.types.nullOr lib.types.str;
        };

        ntfyUrl = lib.mkOption {
          description = "The URL to the ntfy-sh topic.";
          example = "https://push.example.com/grafana";
          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 8080;
          description = "Port to listen on.";
          type = lib.types.port;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.settings.bauthUser == null) == (cfg.settings.bauthPass == null);
        message = "services.grafana-to-ntfy: bauthUser and bauthPass must both be set or both be null";
      }
      {
        assertion = (cfg.settings.ntfyBAuthUser == null) == (cfg.settings.ntfyBAuthPass == null);
        message = "services.grafana-to-ntfy: ntfyBAuthUser and ntfyBAuthPass must both be set or both be null";
      }
    ];

    systemd.services.grafana-to-ntfy = {
      after = [ "network-online.target" ];
      description = "Grafana/Alertmanager to ntfy.sh bridge";

      environment = {
        NTFY_URL = cfg.settings.ntfyUrl;
        ROCKET_ADDRESS = cfg.settings.address;
        ROCKET_PORT = toString cfg.settings.port;
      }
      // lib.optionalAttrs (cfg.settings.bauthUser != null) {
        BAUTH_USER = cfg.settings.bauthUser;
      }
      // lib.optionalAttrs (cfg.settings.ntfyBAuthUser != null) {
        NTFY_BAUTH_USER = cfg.settings.ntfyBAuthUser;
      }
      // lib.optionalAttrs cfg.settings.markdown {
        MARKDOWN = "true";
      };

      script =
        let
          optionalCred = name: envVar: ''
            export ${envVar}="$(${lib.getExe' config.systemd.package "systemd-creds"} cat ${name})"
          '';
        in
        ''
          ${lib.optionalString (cfg.settings.bauthPass != null) (optionalCred "BAUTH_PASS_FILE" "BAUTH_PASS")}
          ${lib.optionalString (cfg.settings.ntfyBAuthPass != null) (
            optionalCred "NTFY_BAUTH_PASS_FILE" "NTFY_BAUTH_PASS"
          )}
          exec ${lib.getExe cfg.package}
        '';

      serviceConfig = {
        # Hardening
        AmbientCapabilities = [ "" ];
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;

        LoadCredential =
          lib.optional (cfg.settings.bauthPass != null) "BAUTH_PASS_FILE:${cfg.settings.bauthPass}"
          ++ lib.optional (
            cfg.settings.ntfyBAuthPass != null
          ) "NTFY_BAUTH_PASS_FILE:${cfg.settings.ntfyBAuthPass}";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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
        RemoveIPC = true;
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
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ kittyandrew ];
}

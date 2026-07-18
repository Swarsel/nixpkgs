{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.nvme-rs;
  opt = options.services.nvme-rs;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.nvme-rs = {
    enable = lib.mkEnableOption "nvme-rs, a monitoring service";
    package = lib.mkPackageOption pkgs "nvme-rs" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for nvme-rs in TOML format.
        See the config.toml example for all available options.
      '';

      type = types.submodule {
        options = {
          check_interval_secs = lib.mkOption {
            default = 3600;
            description = "Check interval in seconds";
            example = 86400;
            type = types.int;
          };

          email = lib.mkOption {
            default = null;
            description = "Email notification configuration";

            type = types.nullOr (
              types.submodule {
                options = {
                  from = lib.mkOption {
                    description = "Sender email address";
                    example = "nvme-monitor@example.com";
                    type = types.str;
                  };

                  smtp_password_file = lib.mkOption {
                    description = "File containing SMTP password";
                    example = "/run/secrets/smtp-password";
                    type = types.path;
                  };

                  smtp_port = lib.mkOption {
                    default = 587;
                    description = "SMTP server port";
                    type = types.port;
                  };

                  smtp_server = lib.mkOption {
                    default = "smtp.gmail.com";
                    description = "SMTP server address";
                    example = "mail.example.com";
                    type = types.str;
                  };

                  smtp_username = lib.mkOption {
                    description = "SMTP username";
                    example = "your-email@gmail.com";
                    type = types.str;
                  };

                  to = lib.mkOption {
                    description = "Recipient email address";
                    example = "admin@example.com";
                    type = types.str;
                  };

                  use_tls = lib.mkOption {
                    default = true;
                    description = "Use TLS for SMTP connection";
                    type = types.bool;
                  };
                };

                freeformType = settingsFormat.type;
              }
            );
          };

          thresholds = lib.mkOption {
            default = { };
            description = "Threshold configuration for NVMe monitoring";

            type = types.submodule {
              options = {
                error_threshold = lib.mkOption {
                  default = 100;
                  description = "Error count warning threshold";
                  type = types.int;
                };

                spare_warning = lib.mkOption {
                  default = 50;
                  description = "Available spare warning threshold (%)";
                  type = types.int;
                };

                temp_critical = lib.mkOption {
                  default = 65;
                  description = "Temperature critical threshold (°C)";
                  type = types.int;
                };

                temp_warning = lib.mkOption {
                  default = 55;
                  description = "Temperature warning threshold (°C)";
                  type = types.int;
                };

                wear_critical = lib.mkOption {
                  default = 50;
                  description = "Wear critical threshold (%)";
                  type = types.int;
                };

                wear_warning = lib.mkOption {
                  default = 20;
                  description = "Wear warning threshold (%)";
                  type = types.int;
                };
              };

              freeformType = settingsFormat.type;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.nvme-rs.settings = opt.settings.default;

    systemd.services.nvme-rs = {
      after = [ "network.target" ];
      description = "NVMe health monitoring service";

      serviceConfig =
        let
          settingsWithoutNull =
            if cfg.settings.email == null then lib.removeAttrs cfg.settings [ "email" ] else cfg.settings;
          configFile = settingsFormat.generate "nvme-rs.toml" settingsWithoutNull;
        in
        {
          AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
          CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
          DynamicUser = true;

          ExecStart = lib.escapeShellArgs [
            "${lib.getExe cfg.package}"
            "daemon"
            "--config"
            "${configFile}"
          ];

          LimitCORE = 0;
          LimitNOFILE = 65535;
          LockPersonality = true;
          MemorySwapMax = 0;
          MemoryZSwapMax = 0;
          NoNewPrivileges = true;
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
          Restart = "on-failure";
          RestartSec = "10s";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          SupplementaryGroups = [ "disk" ];
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "@resources"
            "~@privileged"
          ];

          UMask = "0077";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

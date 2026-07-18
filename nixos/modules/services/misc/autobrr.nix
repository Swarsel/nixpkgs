{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.autobrr;
  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "autobrr.toml" cfg.settings;
in
{
  options = {
    services.autobrr = {
      enable = lib.mkEnableOption "Autobrr";
      package = lib.mkPackageOption pkgs "autobrr" { };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Autobrr web interface.";
        type = lib.types.bool;
      };

      secretFile = lib.mkOption {
        description = "File containing the session secret for the Autobrr web interface.";
        type = lib.types.path;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Autobrr configuration options.

          Refer to <https://autobrr.com/configuration/autobrr>
          for a full list.
        '';

        example = {
          logLevel = "DEBUG";
          port = 7654;
        };

        type = lib.types.submodule {
          options = {
            checkForUpdates = lib.mkOption {
              default = true;
              description = "Whether autobrr needs to check for updates.";
              type = lib.types.bool;
            };

            host = lib.mkOption {
              default = "127.0.0.1";
              description = "The host address autobrr listens on.";
              type = lib.types.str;
            };

            port = lib.mkOption {
              default = 7474;
              description = "The port autobrr listens on.";
              type = lib.types.port;
            };
          };

          freeformType = configFormat.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? sessionSecret);

        message = ''
          Session secrets should not be passed via settings, as
          these are stored in the world-readable nix store.

          Use the secretFile option instead.'';
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.settings.port ]; };

    systemd = {
      services.autobrr = {
        after = [
          "syslog.target"
          "network-online.target"
        ];

        description = "Autobrr";
        restartTriggers = [ configFile ];

        serviceConfig = {
          DynamicUser = true;
          Environment = [ "AUTOBRR__SESSION_SECRET_FILE=%d/sessionSecret" ];
          ExecStart = "${lib.getExe cfg.package} --config %S/autobrr";
          LoadCredential = "sessionSecret:${cfg.secretFile}";
          Restart = "on-failure";
          StateDirectory = "autobrr";
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

      tmpfiles.settings = {
        "10-autobrr" = {
          # DynamicUser uses /var/lib/private/
          "/var/lib/private/autobrr/config.toml"."L+" = {
            argument = "${configFile}";
          };
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ av-gal ];
}

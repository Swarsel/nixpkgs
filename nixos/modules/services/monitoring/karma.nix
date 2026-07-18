{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.karma;
  yaml = pkgs.formats.yaml { };
in
{
  options.services.karma = {
    enable = lib.mkEnableOption "the Karma dashboard service";
    package = lib.mkPackageOption pkgs "karma" { };

    configFile = lib.mkOption {
      default = yaml.generate "karma.yaml" cfg.settings;
      defaultText = "A configuration file generated from the provided nix attributes settings option.";

      description = ''
        A YAML config file which can be used to configure karma instead of the nix-generated file.
      '';

      example = "/etc/karma/karma.conf";
      type = lib.types.path;
    };

    environment = lib.mkOption {
      default = { };

      description = ''
        Additional environment variables to provide to karma.
      '';

      example = {
        ALERTMANAGER_NAME = "single";
        ALERTMANAGER_URI = "https://alertmanager.example.com";
      };

      type = with lib.types; attrsOf str;
    };

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line options.
      '';

      example = [
        "--alertmanager.timeout 10s"
      ];

      type = with lib.types; listOf str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open ports in the firewall needed for karma to function.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = {
        listen = {
          address = "127.0.0.1";
        };
      };

      description = ''
        Karma dashboard configuration as nix attributes.

        Reference: <https://github.com/prymitive/karma/blob/main/docs/CONFIGURATION.md>
      '';

      example = {
        alertmanager = {
          interval = "15s";

          servers = [
            {
              name = "prod";
              uri = "http://alertmanager.example.com";
            }
          ];
        };

        listen = {
          address = "192.168.1.4";
          port = "8000";
          prefix = "/dashboard";
        };
      };

      type = lib.types.submodule {
        options.listen = {
          address = lib.mkOption {
            default = "127.0.0.1";

            description = ''
              Hostname or IP to listen on.
            '';

            example = "[::]";
            type = lib.types.str;
          };

          port = lib.mkOption {
            default = 8080;

            description = ''
              HTTP port to listen on.
            '';

            example = 8182;
            type = lib.types.port;
          };
        };

        freeformType = yaml.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.listen.port ];

    systemd.services.karma = {
      description = "Alert dashboard for Prometheus Alertmanager";
      environment = cfg.environment;

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --config.file ${cfg.configFile} ${lib.concatStringsSep " " cfg.extraOptions}";
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

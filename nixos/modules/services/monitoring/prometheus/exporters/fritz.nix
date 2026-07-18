{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.services.prometheus.exporters.fritz;
  yaml = pkgs.formats.yaml { };
  configFile = yaml.generate "fritz-exporter.yaml" cfg.settings;
in
{
  extraOpts = {
    settings = mkOption {
      description = "Configuration settings for fritz-exporter.";

      type = types.submodule {
        options = {
          devices = mkOption {
            default = [ ];
            description = "Fritz!-devices to monitor using the exporter.";

            type =
              with types;
              listOf (submodule {
                options = {
                  host_info = mkOption {
                    default = false;

                    description = ''
                      Enable extended host info for this device. *Warning*: This will heavily increase scrape time.
                    '';

                    type = types.bool;
                  };

                  hostname = mkOption {
                    default = "fritz.box";

                    description = ''
                      Hostname under which the target device is reachable.
                    '';

                    type = types.str;
                  };

                  name = mkOption {
                    default = "";

                    description = ''
                      Name to use for the device.
                    '';

                    type = types.str;
                  };

                  password_file = mkOption {
                    description = ''
                      Path to a file which contains the password to authenticate with the target device.
                      Needs to be readable by the user the exporter runs under.
                    '';

                    type = types.path;
                  };

                  username = mkOption {
                    description = ''
                      Username to authenticate with the target device.
                    '';

                    type = types.str;
                  };
                };

                freeformType = yaml.type;
              });
          };

          # Pull existing listen address option into config file.
          listen_address = mkOption {
            default = cfg.listenAddress;
            internal = true;
            type = types.str;
            visible = false;
          };

          log_level = mkOption {
            default = "INFO";

            description = ''
              Log level to use for the exporter.
            '';

            type = types.enum [
              "DEBUG"
              "INFO"
              "WARNING"
              "ERROR"
              "CRITICAL"
            ];
          };

          # Pull existing port option into config file.
          port = mkOption {
            default = cfg.port;
            internal = true;
            type = types.port;
            visible = false;
          };
        };

        freeformType = yaml.type;
      };
    };
  };

  port = 9787;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;

      ExecStart = utils.escapeSystemdExecArgs (
        [
          (lib.getExe pkgs.fritz-exporter)
          "--config"
          configFile
        ]
        ++ cfg.extraFlags
      );
    };
  };
}

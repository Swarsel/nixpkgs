{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hardware.uni-sync;
in
{
  options.hardware.uni-sync = {
    enable = mkEnableOption "udev rules and software for Lian Li Uni Controllers";
    package = mkPackageOption pkgs "uni-sync" { };

    devices = mkOption {
      default = [ ];
      description = "List of controllers with their configurations.";

      example = literalExpression ''
        [
          {
            device_id = "VID:1111/PID:11111/SN:1111111111";
            sync_rgb = true;
            channels = [
              {
                mode = "PWM";
              }
              {
                mode = "Manual";
                speed = 100;
              }
              {
                mode = "Manual";
                speed = 54;
              }
              {
                mode = "Manual";
                speed = 0;
              }
            ];
          }
          {
            device_id = "VID:1010/PID:10101/SN:1010101010";
            sync_rgb = false;
            channels = [
              {
                mode = "Manual";
                speed = 0;
              }
            ];
          }
        ]
      '';

      type = types.listOf (
        types.submodule {
          options = {
            channels = mkOption {
              default = [ ];
              description = "List of channels connected to the controller.";

              example = literalExpression ''
                [
                  {
                    mode = "PWM";
                  }
                  {
                    mode = "Manual";
                    speed = 100;
                  }
                  {
                    mode = "Manual";
                    speed = 54;
                  }
                  {
                    mode = "Manual";
                    speed = 0;
                  }
                ]
              '';

              type = types.listOf (
                types.submodule {
                  options = {
                    mode = mkOption {
                      default = "Manual";
                      description = "\"PWM\" to enable PWM sync. \"Manual\" to set speed.";
                      example = "PWM";

                      type = types.enum [
                        "Manual"
                        "PWM"
                      ];
                    };

                    speed = mkOption {
                      default = "50";
                      description = "Fan speed as percentage (clamped between 0 and 100).";
                      example = "100";
                      type = types.int;
                    };
                  };
                }
              );
            };

            device_id = mkOption {
              description = "Unique device ID displayed at each startup.";
              example = "VID:1111/PID:11111/SN:1111111111";
              type = types.str;
            };

            sync_rgb = mkOption {
              default = false;
              description = "Enable ARGB header sync.";
              example = true;
              type = types.bool;
            };
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    environment.etc."uni-sync/uni-sync.json".text = mkIf (cfg.devices != [ ]) (
      builtins.toJSON { configs = cfg.devices; }
    );

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
  };

  meta.maintainers = with maintainers; [ yunfachi ];
}

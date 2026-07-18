{
  config,
  lib,
  pkgs,
  ...
}:
let
  configFormat = pkgs.formats.json { };
  cfg = config.hardware.fw-fanctrl;
in
{
  options.hardware.fw-fanctrl = {
    config = lib.mkOption {
      default = { };

      description = ''
        Additional config entries for the fw-fanctrl service (documentation: <https://github.com/TamtamHero/fw-fanctrl/blob/main/doc/configuration.md>)
      '';

      type = lib.types.submodule {
        options = {
          defaultStrategy = lib.mkOption {
            default = "lazy";
            description = "Default strategy to use";
            type = lib.types.str;
          };

          strategies = lib.mkOption {
            default = { };

            description = ''
              Additional strategies which can be used by fw-fanctrl
            '';

            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  fanSpeedUpdateFrequency = lib.mkOption {
                    default = 5;
                    description = "How often the fan speed should be updated in seconds";
                    type = lib.types.ints.unsigned;
                  };

                  movingAverageInterval = lib.mkOption {
                    default = 25;
                    description = "Interval (seconds) of the last temperatures to use to calculate the average temperature";
                    type = lib.types.ints.unsigned;
                  };

                  speedCurve = lib.mkOption {
                    default = [ ];
                    description = "How should the speed curve look like";

                    type = lib.types.listOf (
                      lib.types.submodule {
                        options = {
                          speed = lib.mkOption {
                            default = 0;
                            description = "Percent how fast the fan should run at";
                            type = lib.types.ints.between 0 100;
                          };

                          temp = lib.mkOption {
                            default = 0;
                            description = "Temperature in °C at which the fan speed should be changed";
                            type = lib.types.int;
                          };

                        };
                      }
                    );
                  };
                };
              }
            );
          };

          strategyOnDischarging = lib.mkOption {
            default = "";
            description = "Default strategy on discharging";
            type = lib.types.str;
          };
        };

        freeformType = lib.types.attrsOf configFormat.type;
      };
    };

    enable = lib.mkEnableOption "the fw-fanctrl systemd service and install the needed packages";
    package = lib.mkPackageOption pkgs "fw-fanctrl" { };

    disableBatteryTempCheck = lib.mkOption {
      default = false;

      description = ''
        Disable checking battery temperature sensor
      '';

      type = lib.types.bool;
    };

    ectoolPackage = lib.mkPackageOption pkgs "fw-ectool" { };
  };

  config =
    let
      defaultConfig = builtins.fromJSON (builtins.readFile "${cfg.package}/share/fw-fanctrl/config.json");
      finalConfig = lib.attrsets.recursiveUpdate defaultConfig cfg.config;
      configFile = configFormat.generate "custom.json" finalConfig;
    in
    lib.mkIf cfg.enable {
      # Create suspend config
      environment.etc."systemd/system-sleep/fw-fanctrl-suspend.sh".source =
        "${cfg.package}/share/fw-fanctrl/fw-fanctrl-suspend";

      environment.systemPackages = [
        cfg.package
        cfg.ectoolPackage
      ];

      systemd.services.fw-fanctrl = {
        after = [ "multi-user.target" ];
        description = "Framework Fan Controller";

        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package} --output-format JSON run --config ${configFile} --silent ${lib.optionalString cfg.disableBatteryTempCheck "--no-battery-sensors"}";
          ExecStopPost = "${lib.getExe cfg.ectoolPackage} autofanctrl";
          Restart = "always";
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta = {
    maintainers = [ lib.maintainers.Svenum ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.auto-epp;
  format = pkgs.formats.ini { };

  inherit (lib) mkOption types;
in
{
  options = {
    services.auto-epp = {
      enable = lib.mkEnableOption "auto-epp for amd active pstate";
      package = lib.mkPackageOption pkgs "auto-epp" { };

      settings = mkOption {
        default = { };

        description = ''
          Settings for the auto-epp application.
          See upstream example: <https://github.com/jothi-prasath/auto-epp/blob/master/sample-auto-epp.conf>
        '';

        type = types.submodule {
          options = {
            Settings = {
              epp_state_for_AC = mkOption {
                default = "balance_performance";

                description = ''
                  energy_performance_preference when on plugged in

                  ::: {.note}
                  See available epp states by running:
                  {command}`cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences`
                  :::
                '';

                type = types.str;
              };

              epp_state_for_BAT = mkOption {
                default = "power";

                description = ''
                  `energy_performance_preference` when on battery

                  ::: {.note}
                  See available epp states by running:
                  {command}`cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences`
                  :::
                '';

                type = types.str;
              };
            };
          };

          freeformType = format.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    boot.kernelParams = [
      "amd_pstate=active"
    ];

    environment.etc."auto-epp.conf".source = format.generate "auto-epp.conf" cfg.settings;
    systemd.packages = [ cfg.package ];

    systemd.services.auto-epp = {
      after = [ "multi-user.target" ];
      description = "auto-epp - Automatic EPP Changer for amd-pstate-epp";

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        Type = "simple";
        User = "root";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ lamarios ];
}

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cpupower = config.boot.kernelPackages.cpupower;
  cfg = config.powerManagement;
in

{
  ###### interface

  options.powerManagement = {

    # TODO: This should be aliased to powerManagement.cpufreq.governor.
    # https://github.com/NixOS/nixpkgs/pull/53041#commitcomment-31825338
    cpuFreqGovernor = mkOption {
      default = null;

      description = ''
        Configure the governor used to regulate the frequency of the
        available CPUs. By default, the kernel configures the
        performance governor, although this may be overwritten in your
        hardware-configuration.nix file.

        Often used values: "ondemand", "powersave", "performance"
      '';

      example = "ondemand";
      type = types.nullOr types.str;
    };

    cpufreq = {

      max = mkOption {
        default = null;

        description = ''
          The maximum frequency the CPU will use.  Defaults to the maximum possible.
        '';

        example = 2200000;
        type = types.nullOr types.ints.unsigned;
      };

      min = mkOption {
        default = null;

        description = ''
          The minimum frequency the CPU will use.
        '';

        example = 800000;
        type = types.nullOr types.ints.unsigned;
      };
    };

  };

  ###### implementation

  config =
    let
      governorEnable = cfg.cpuFreqGovernor != null;
      maxEnable = cfg.cpufreq.max != null;
      minEnable = cfg.cpufreq.min != null;
      enable = !config.boot.isContainer && (governorEnable || maxEnable || minEnable);
    in
    mkIf enable {

      boot.kernelModules = optional governorEnable "cpufreq_${cfg.cpuFreqGovernor}";
      environment.systemPackages = [ cpupower ];

      systemd.services.cpufreq = {
        after = [ "systemd-modules-load.service" ];
        description = "CPU Frequency Setup";

        path = [
          cpupower
          pkgs.kmod
        ];

        serviceConfig = {
          ExecStart =
            "${cpupower}/bin/cpupower frequency-set "
            + optionalString governorEnable "--governor ${cfg.cpuFreqGovernor} "
            + optionalString maxEnable "--max ${toString cfg.cpufreq.max} "
            + optionalString minEnable "--min ${toString cfg.cpufreq.min} ";

          RemainAfterExit = "yes";
          SuccessExitStatus = "0 237";
          Type = "oneshot";
        };

        unitConfig.ConditionVirtualization = false;
        wantedBy = [ "multi-user.target" ];
      };

    };
}

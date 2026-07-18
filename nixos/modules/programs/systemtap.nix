{ config, lib, ... }:

let
  cfg = config.programs.systemtap;
in
{

  options = {
    programs.systemtap = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Install {command}`systemtap` along with necessary kernel options.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.features.debug = true;

    environment.systemPackages = [
      config.boot.kernelPackages.systemtap
    ];

    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isYes "DEBUG")
    ];
  };

}

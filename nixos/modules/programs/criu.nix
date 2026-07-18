{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.criu;
in
{

  options = {
    programs.criu = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Install {command}`criu` along with necessary kernel options.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.features.criu = true;
    environment.systemPackages = [ pkgs.criu ];

    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isYes "CHECKPOINT_RESTORE")
    ];
  };

}

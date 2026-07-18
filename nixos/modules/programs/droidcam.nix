{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.droidcam = {
    enable = lib.mkEnableOption "DroidCam client";
  };

  config = lib.mkIf config.programs.droidcam.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    boot.kernelModules = [
      "v4l2loopback"
      "snd-aloop"
    ];

    environment.systemPackages = [ pkgs.droidcam ];
  };
}

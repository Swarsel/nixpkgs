{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.usbtop;
in
{
  options = {
    programs.usbtop.enable = lib.mkEnableOption "usbtop and required kernel module, to show estimated USB bandwidth";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "usbmon"
    ];

    environment.systemPackages = with pkgs; [
      usbtop
    ];
  };
}

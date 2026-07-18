{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.brillo;
in
{
  options = {
    hardware.brillo = {
      enable = lib.mkEnableOption ''
        brillo in userspace.
        This will allow brightness control from users in the video group
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.brillo ];
    services.udev.packages = [ pkgs.brillo ];
  };
}

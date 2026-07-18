{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.acpilight;
in
{
  options = {
    hardware.acpilight = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable acpilight.
          This will allow brightness control via xbacklight from users in the video group
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ acpilight ];
    services.udev.packages = with pkgs; [ acpilight ];
  };
}

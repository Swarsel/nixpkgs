{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.calls;
in
{
  options = {
    programs.calls = {
      enable = lib.mkEnableOption ''
        GNOME calls: a phone dialer and call handler
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.calls
    ];

    programs.dconf.enable = true;

    services.dbus.packages = [
      pkgs.callaudiod
    ];
  };
}

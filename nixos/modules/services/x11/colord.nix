{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.colord;

in
{

  options = {

    services.colord = {
      enable = mkEnableOption "colord, the color management daemon";
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.colord ];
    services.dbus.packages = [ pkgs.colord ];
    services.udev.packages = [ pkgs.colord ];
    systemd.packages = [ pkgs.colord ];
    systemd.tmpfiles.packages = [ pkgs.colord ];
    users.groups.colord = { };

    users.users.colord = {
      group = "colord";
      home = "/var/lib/colord";
      isSystemUser = true;
    };

  };

}

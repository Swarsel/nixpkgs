# Tumbler
{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.tumbler;

in

{

  imports = [
    (lib.mkRemovedOptionModule [ "services" "tumbler" "package" ] "")
  ];

  ###### interface
  options = {

    services.tumbler = {

      enable = lib.mkEnableOption "Tumbler, A D-Bus thumbnailer service";

    };

  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      tumbler
    ];

    services.dbus.packages = with pkgs; [
      tumbler
    ];

  };

  meta = {
    teams = [ lib.teams.pantheon ];
  };

}

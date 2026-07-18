# GNOME Terminal.

{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.programs.gnome-terminal;

in

{

  options = {
    programs.gnome-terminal.enable = lib.mkEnableOption "GNOME Terminal";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gnome-terminal ];
    programs.bash.vteIntegration = true;
    programs.zsh.vteIntegration = true;
    services.dbus.packages = [ pkgs.gnome-terminal ];
    systemd.packages = [ pkgs.gnome-terminal ];
  };

  meta = {
    teams = [ lib.teams.gnome ];
  };
}

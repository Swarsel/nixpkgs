{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nm-applet;
in
{
  options.programs.nm-applet = {
    enable = lib.mkEnableOption "nm-applet, a NetworkManager control applet for GNOME";
    package = lib.mkPackageOption pkgs "networkmanagerapplet" { };

    indicator = lib.mkOption {
      default = true;

      description = ''
        Whether to use indicator instead of status icon.
        It is needed for Appindicator environments, like Enlightenment.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ pkgs.gcr ];

    systemd.user.services.nm-applet = {
      after = [ "graphical-session.target" ];
      description = "Network manager applet";
      partOf = [ "graphical-session.target" ];
      serviceConfig.ExecStart = "${cfg.package}/bin/nm-applet ${lib.optionalString cfg.indicator "--indicator"}";
      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta = {
    teams = [ lib.teams.freedesktop ];
  };
}

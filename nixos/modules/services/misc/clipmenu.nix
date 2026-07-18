{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.clipmenu;
in
{

  options.services.clipmenu = {
    enable = lib.mkEnableOption "clipmenu, the clipboard management daemon";
    package = lib.mkPackageOption pkgs "clipmenu" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.clipmenu = {
      enable = true;
      after = [ "graphical-session.target" ];
      description = "Clipboard management daemon";
      serviceConfig.ExecStart = "${cfg.package}/bin/clipmenud";
      wantedBy = [ "graphical-session.target" ];
    };
  };
}

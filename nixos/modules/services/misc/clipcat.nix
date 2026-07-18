{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.clipcat;
in
{

  options.services.clipcat = {
    enable = lib.mkEnableOption "Clipcat clipboard daemon";
    package = lib.mkPackageOption pkgs "clipcat" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.clipcat = {
      enable = true;
      after = [ "graphical-session.target" ];
      description = "clipcat daemon";
      serviceConfig.ExecStart = "${cfg.package}/bin/clipcatd --no-daemon";
      wantedBy = [ "graphical-session.target" ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.greenclip;
in
{

  options.services.greenclip = {
    enable = lib.mkEnableOption "Greenclip, a clipboard manager";
    package = lib.mkPackageOption pkgs [ "haskellPackages" "greenclip" ] { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.greenclip = {
      enable = true;
      after = [ "graphical-session.target" ];
      description = "greenclip daemon";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/greenclip daemon";
        Restart = "always";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };
}

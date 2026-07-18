{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.devmon;

in
{
  options = {
    services.devmon = {
      enable = lib.mkEnableOption "devmon, an automatic device mounting daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udisks2.enable = true;

    systemd.user.services.devmon = {
      description = "devmon automatic device mounting daemon";

      path = [
        pkgs.udevil
        pkgs.procps
        pkgs.udisks
        pkgs.which
      ];

      serviceConfig.ExecStart = "${pkgs.udevil}/bin/devmon";
      wantedBy = [ "default.target" ];
    };
  };
}

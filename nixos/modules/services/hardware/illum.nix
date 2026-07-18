{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.illum;
in
{

  options = {

    services.illum = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable illum, a daemon for controlling screen brightness with brightness buttons.
        '';

        type = lib.types.bool;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.illum = {
      description = "Backlight Adjustment Service";
      serviceConfig.ExecStart = "${pkgs.illum}/bin/illum-d";
      serviceConfig.Restart = "on-failure";
      wantedBy = [ "multi-user.target" ];
    };

  };

}

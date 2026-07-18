{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sundtek;

in
{
  options.services.sundtek = {
    enable = lib.mkEnableOption "Sundtek driver";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.sundtek ];

    systemd.services.sundtek = {
      description = "Sundtek driver";

      serviceConfig = {
        ExecStart = ''
          ${pkgs.sundtek}/bin/mediasrv -d -v -p ${pkgs.sundtek}/bin ;\
          ${pkgs.sundtek}/bin/mediaclient --start --wait-for-devices
        '';

        ExecStop = "${pkgs.sundtek}/bin/mediaclient --shutdown";
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

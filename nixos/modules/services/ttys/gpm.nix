{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.gpm;

in

{

  ###### interface

  options = {

    services.gpm = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable GPM, the General Purpose Mouse daemon,
          which enables mouse support in virtual consoles.
        '';

        type = types.bool;
      };

      protocol = mkOption {
        default = "ps/2";
        description = "Mouse protocol to use.";
        type = types.str;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.gpm = {
      after = [ "dev-input-mice.device" ];
      description = "Console Mouse Daemon";
      requires = [ "dev-input-mice.device" ];
      serviceConfig.ExecStart = "@${pkgs.gpm}/sbin/gpm gpm -m /dev/input/mice -t ${cfg.protocol}";
      serviceConfig.PIDFile = "/run/gpm.pid";
      serviceConfig.Type = "forking";
      wantedBy = [ "multi-user.target" ];
    };

  };

}

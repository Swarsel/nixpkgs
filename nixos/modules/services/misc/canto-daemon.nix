{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.canto-daemon;

in
{

  ##### interface

  options = {

    services.canto-daemon = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the canto RSS daemon.";
        type = lib.types.bool;
      };
    };

  };

  ##### implementation

  config = lib.mkIf cfg.enable {

    systemd.user.services.canto-daemon = {
      after = [ "network.target" ];
      description = "Canto RSS Daemon";
      serviceConfig.ExecStart = "${pkgs.canto-daemon}/bin/canto-daemon";
      wantedBy = [ "default.target" ];
    };
  };

}

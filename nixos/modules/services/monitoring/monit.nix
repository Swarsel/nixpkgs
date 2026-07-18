{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.monit;
in

{
  options.services.monit = {

    config = lib.mkOption {
      default = "";
      description = "monitrc content";
      type = lib.types.lines;
    };

    enable = lib.mkEnableOption "Monit";

  };

  config = lib.mkIf cfg.enable {

    environment.etc.monitrc = {
      mode = "0400";
      text = cfg.config;
    };

    environment.systemPackages = [ pkgs.monit ];

    systemd.services.monit = {
      after = [ "network.target" ];
      description = "Pro-active monitoring utility for unix systems";
      restartTriggers = [ config.environment.etc.monitrc.source ];

      serviceConfig = {
        ExecReload = "${pkgs.monit}/bin/monit -c /etc/monitrc reload";
        ExecStart = "${pkgs.monit}/bin/monit -I -c /etc/monitrc";
        ExecStop = "${pkgs.monit}/bin/monit -c /etc/monitrc quit";
        KillMode = "process";
        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ ryantm ];
}

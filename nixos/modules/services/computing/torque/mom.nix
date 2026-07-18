{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.torque.mom;
  torque = pkgs.torque;

  momConfig = pkgs.writeText "torque-mom-config" ''
    $pbsserver ${cfg.serverNode}
    $logevent 225
  '';

in
{
  options = {

    services.torque.mom = {
      enable = lib.mkEnableOption "torque computing node";

      serverNode = lib.mkOption {
        description = "Hostname running pbs server.";
        type = lib.types.str;
      };

    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.torque ];

    systemd.services.torque-mom = {
      after = [
        "torque-mom-init.service"
        "network.target"
      ];

      path = [ torque ];
      requires = [ "torque-mom-init.service" ];

      serviceConfig = {
        ExecStart = "${torque}/bin/pbs_mom";
        PIDFile = "/var/spool/torque/mom_priv/mom.lock";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.torque-mom-init = {
      path = with pkgs; [
        torque
        util-linux
        procps
        inetutils
      ];

      script = ''
        pbs_mkdirs -v aux
        pbs_mkdirs -v mom
        hostname > /var/spool/torque/server_name
        cp -v ${momConfig} /var/spool/torque/mom_priv/config
      '';

      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = "!/var/spool/torque";
    };

  };
}

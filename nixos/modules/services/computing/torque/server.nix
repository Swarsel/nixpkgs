{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.torque.server;
  torque = pkgs.torque;
in
{
  options = {

    services.torque.server = {

      enable = lib.mkEnableOption "torque server";

    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.torque ];

    systemd.services.torque-scheduler = {
      after = [ "torque-server-init.service" ];
      documentation = [ "man:pbs_sched(8)" ];
      path = [ torque ];
      requires = [ "torque-server-init.service" ];

      serviceConfig = {
        ExecStart = "${torque}/bin/pbs_sched";
        PIDFile = "/var/spool/torque/sched_priv/sched.lock";
        Type = "forking";
      };
    };

    systemd.services.torque-server = {
      after = [
        "torque-server-init.service"
        "network.target"
      ];

      before = [ "trqauthd.service" ];
      documentation = [ "man:pbs_server(8)" ];
      path = [ torque ];
      requires = [ "torque-server-init.service" ];

      serviceConfig = {
        ExecStart = "${torque}/bin/pbs_server";
        ExecStop = "${torque}/bin/qterm";
        PIDFile = "/var/spool/torque/server_priv/server.lock";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "torque-scheduler.service"
        "trqauthd.service"
      ];
    };

    systemd.services.torque-server-init = {
      path = with pkgs; [
        torque
        util-linux
        procps
        inetutils
      ];

      script = ''
        tmpsetup=$(mktemp -t torque-XXXX)
        cp -p ${torque}/bin/torque.setup $tmpsetup
        sed -i $tmpsetup -e 's/pbs_server -t create/pbs_server -f -t create/'

        pbs_mkdirs -v aux
        pbs_mkdirs -v server
        hostname > /var/spool/torque/server_name
        cp -prv ${torque}/var/spool/torque/* /var/spool/torque/
        $tmpsetup root

        sleep 1
        rm -f $tmpsetup
        kill $(pgrep pbs_server) 2>/dev/null
        kill $(pgrep trqauthd) 2>/dev/null
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      unitConfig = {
        ConditionPathExists = "!/var/spool/torque";
      };
    };

    systemd.services.trqauthd = {
      after = [ "torque-server-init.service" ];
      path = [ torque ];
      requires = [ "torque-server-init.service" ];

      serviceConfig = {
        ExecStart = "${torque}/bin/trqauthd";
        Type = "forking";
      };
    };

  };
}

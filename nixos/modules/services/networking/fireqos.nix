{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fireqos;
  fireqosConfig = pkgs.writeText "fireqos.conf" cfg.config;
in
{
  options.services.fireqos = {
    config = lib.mkOption {
      description = ''
        The FireQOS configuration.
      '';

      example = ''
        interface wlp3s0 world-in input rate 10mbit ethernet
          class web commit 50kbit
            match tcp ports 80,443

        interface wlp3s0 world-out input rate 10mbit ethernet
          class web commit 50kbit
            match tcp ports 80,443
      '';

      type = lib.types.lines;
    };

    enable = lib.mkEnableOption "FireQOS";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.fireqos = {
      after = [ "network.target" ];
      description = "FireQOS";

      serviceConfig = {
        ExecStart = "${pkgs.firehol}/bin/fireqos start ${fireqosConfig}";

        ExecStop = [
          "${pkgs.firehol}/bin/fireqos stop"
          "${pkgs.firehol}/bin/fireqos clear_all_qos"
        ];

        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

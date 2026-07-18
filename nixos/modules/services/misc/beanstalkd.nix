{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.beanstalkd;
  pkg = pkgs.beanstalkd;
in

{
  # interface

  options = {
    services.beanstalkd = {
      enable = lib.mkEnableOption "the Beanstalk work queue";

      listen = {
        address = lib.mkOption {
          default = "127.0.0.1";
          description = "IP address to listen on.";
          example = "0.0.0.0";
          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 11300;
          description = "TCP port that will be used to accept client connections.";
          type = lib.types.port;
        };
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open ports in the firewall for the server.";
        type = lib.types.bool;
      };
    };
  };

  # implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };

    systemd.services.beanstalkd = {
      after = [ "network.target" ];
      description = "Beanstalk Work Queue";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkg}/bin/beanstalkd -l ${cfg.listen.address} -p ${toString cfg.listen.port} -b $STATE_DIRECTORY";
        Restart = "always";
        StateDirectory = "beanstalkd";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };
}

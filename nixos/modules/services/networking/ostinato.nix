{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  pkg = pkgs.ostinato;
  cfg = config.services.ostinato;
  configFile = pkgs.writeText "drone.ini" ''
    [General]
    RateAccuracy=${cfg.rateAccuracy}

    [RpcServer]
    Address=${cfg.rpcServer.address}

    [PortList]
    Include=${concatStringsSep "," cfg.portList.include}
    Exclude=${concatStringsSep "," cfg.portList.exclude}
  '';

in
{

  ###### interface

  options = {

    services.ostinato = {

      enable = mkEnableOption "Ostinato agent-controller (Drone)";

      port = mkOption {
        default = 7878;

        description = ''
          Port to listen on.
        '';

        type = types.port;
      };

      portList = {
        exclude = mkOption {
          default = [ ];

          description = ''
            A list of ports does not appear on the port list managed by drone.
          '';

          example = [
            "usbmon*"
            "eth0"
          ];

          type = types.listOf types.str;
        };

        include = mkOption {
          default = [ ];

          description = ''
            For a port to pass the filter and appear on the port list managed
            by drone, it be allowed by this include list.
          '';

          example = [
            "eth*"
            "lo*"
          ];

          type = types.listOf types.str;
        };
      };

      rateAccuracy = mkOption {
        default = "High";

        description = ''
          To ensure that the actual transmit rate is as close as possible to
          the configured transmit rate, Drone runs a busy-wait loop.
          While this provides the maximum accuracy possible, the CPU
          utilization is 100% while the transmit is on. You can however,
          sacrifice the accuracy to reduce the CPU load.
        '';

        type = types.enum [
          "High"
          "Low"
        ];
      };

      rpcServer = {
        address = mkOption {
          default = "0.0.0.0";

          description = ''
            By default, the Drone RPC server will listen on all interfaces and
            local IPv4 addresses for incoming connections from clients.  Specify
            a single IPv4 or IPv6 address if you want to restrict that.
            To listen on any IPv6 address, use ::
          '';

          type = types.str;
        };
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    systemd.services.drone = {
      description = "Ostinato agent-controller";

      script = ''
        ${pkg}/bin/drone ${toString cfg.port} ${configFile}
      '';

      wantedBy = [ "multi-user.target" ];
    };

  };

}

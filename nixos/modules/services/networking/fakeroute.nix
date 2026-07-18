{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.fakeroute;
  routeConf = pkgs.writeText "route.conf" (lib.concatStringsSep "\n" cfg.route);

in

{

  ###### interface

  options = {

    services.fakeroute = {

      enable = lib.mkEnableOption "the fakeroute service";

      route = lib.mkOption {
        default = [ ];

        description = ''
          Fake route that will appear after the real
          one to any host running a traceroute.
        '';

        example = [
          "216.102.187.130"
          "4.0.1.122"
          "198.116.142.34"
          "63.199.8.242"
        ];

        type = with lib.types; listOf str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.fakeroute = {
      after = [ "network.target" ];
      description = "Fakeroute Daemon";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_RAW" ];
        DynamicUser = true;
        ExecStart = "${pkgs.fakeroute}/bin/fakeroute -f ${routeConf}";
        Type = "forking";
        User = "fakeroute";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}

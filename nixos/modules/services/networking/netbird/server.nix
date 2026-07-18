{ config, lib, ... }:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    ;

  inherit (lib.types) str;

  cfg = config.services.netbird.server;
in

{
  # Import the separate components
  imports = [
    ./coturn.nix
    ./dashboard.nix
    ./management.nix
    ./signal.nix
  ];

  options.services.netbird.server = {
    enable = mkEnableOption "Netbird Server stack, comprising the dashboard, management API and signal service";

    domain = mkOption {
      description = "The domain under which the netbird server runs.";
      type = str;
    };

    enableNginx = mkEnableOption "Nginx reverse-proxy for the netbird server services";
  };

  config = mkIf cfg.enable {
    services.netbird.server = {
      coturn = {
        domain = mkDefault cfg.domain;
      };

      dashboard = {
        enable = mkDefault cfg.enable;
        domain = mkDefault cfg.domain;
        enableNginx = mkDefault cfg.enableNginx;
        managementServer = "https://${cfg.domain}";
      };

      management = {
        enable = mkDefault cfg.enable;
        domain = mkDefault cfg.domain;
        enableNginx = mkDefault cfg.enableNginx;
      }
      // (optionalAttrs cfg.coturn.enable rec {
        # We cannot merge a list of attrsets so we have to redefine the whole list
        settings = {
          TURNConfig.Turns = mkDefault [
            {
              Password =
                if (cfg.coturn.password != null) then
                  cfg.coturn.password
                else
                  { _secret = cfg.coturn.passwordFile; };

              Proto = "udp";
              URI = "turn:${turnDomain}:${toString turnPort}";
              Username = "netbird";
            }
          ];
        };

        turnDomain = cfg.domain;
        turnPort = config.services.coturn.listening-port;
      });

      signal = {
        enable = mkDefault cfg.enable;
        domain = mkDefault cfg.domain;
        enableNginx = mkDefault cfg.enableNginx;
      };
    };
  };

  meta = {
    doc = ./server.md;
    maintainers = with lib.maintainers; [ patrickdag ];
  };
}

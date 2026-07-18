{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mainsail;
  moonraker = config.services.moonraker;
in
{
  options.services.mainsail = {
    enable = mkEnableOption "a modern and responsive user interface for Klipper";
    package = mkPackageOption pkgs "mainsail" { };

    hostName = mkOption {
      default = "localhost";
      description = "Hostname to serve mainsail on";
      type = types.str;
    };

    nginx = mkOption {
      default = { };
      description = "Extra configuration for the nginx virtual host of mainsail.";

      example = literalExpression ''
        {
          serverAliases = [ "mainsail.''${config.networking.domain}" ];
        }
      '';

      type = types.submodule (import ../web-servers/nginx/vhost-options.nix { inherit config lib; });
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      upstreams.mainsail-apiserver.servers."${moonraker.address}:${toString moonraker.port}" = { };

      virtualHosts."${cfg.hostName}" = mkMerge [
        cfg.nginx
        {
          locations = {
            "/" = {
              index = "index.html";
              tryFiles = "$uri $uri/ /index.html";
            };

            "/index.html".extraConfig = ''
              add_header Cache-Control "no-store, no-cache, must-revalidate";
            '';

            "/websocket" = {
              proxyPass = "http://mainsail-apiserver/websocket";
              proxyWebsockets = true;
            };

            "~ ^/(printer|api|access|machine|server)/" = {
              proxyPass = "http://mainsail-apiserver$request_uri";
              proxyWebsockets = true;
            };
          };

          root = mkForce "${cfg.package}/share/mainsail";
        }
      ];
    };
  };
}

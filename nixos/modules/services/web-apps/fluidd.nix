{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.fluidd;
  moonraker = config.services.moonraker;
in
{
  options.services.fluidd = {
    enable = mkEnableOption "Fluidd, a Klipper web interface for managing your 3d printer";
    package = mkPackageOption pkgs "fluidd" { };

    hostName = mkOption {
      default = "localhost";
      description = "Hostname to serve fluidd on";
      type = types.str;
    };

    nginx = mkOption {
      default = { };
      description = "Extra configuration for the nginx virtual host of fluidd.";

      example = literalExpression ''
        {
          serverAliases = [ "fluidd.''${config.networking.domain}" ];
        }
      '';

      type = types.submodule (import ../web-servers/nginx/vhost-options.nix { inherit config lib; });
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      upstreams.fluidd-apiserver.servers."${moonraker.address}:${toString moonraker.port}" = { };

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
              proxyPass = "http://fluidd-apiserver/websocket";
              proxyWebsockets = true;
            };

            "~ ^/(printer|api|access|machine|server)/" = {
              proxyPass = "http://fluidd-apiserver$request_uri";
              proxyWebsockets = true;
            };
          };

          root = mkForce "${cfg.package}/share/fluidd/htdocs";
        }
      ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.networking.websockify;
in
{
  options = {
    services.networking.websockify = {
      enable = mkOption {
        default = false;
        description = "Whether to enable websockify to forward websocket connections to TCP connections.";
        type = types.bool;
      };

      portMap = mkOption {
        default = { };
        description = "Ports to map by default.";
        type = types.attrsOf types.port;
      };

      sslCert = mkOption {
        description = "Path to the SSL certificate.";
        type = types.path;
      };

      sslKey = mkOption {
        default = cfg.sslCert;
        defaultText = literalExpression "config.services.networking.websockify.sslCert";
        description = "Path to the SSL key.";
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services."websockify@" = {
      description = "Service to forward websocket connections to TCP connections (from port:to port %I)";

      script = ''
        IFS=':' read -a array <<< "$1"
        ${pkgs.python3Packages.websockify}/bin/websockify --ssl-only \
          --cert=${cfg.sslCert} --key=${cfg.sslKey} 0.0.0.0:''${array[0]} 0.0.0.0:''${array[1]}
      '';

      scriptArgs = "%i";
    };

    systemd.targets.default-websockify = {
      description = "Target to start all default websockify@ services";
      unitConfig.X-StopOnReconfiguration = true;
      wantedBy = [ "multi-user.target" ];
      wants = mapAttrsToList (name: value: "websockify@${name}:${toString value}.service") cfg.portMap;
    };
  };
}

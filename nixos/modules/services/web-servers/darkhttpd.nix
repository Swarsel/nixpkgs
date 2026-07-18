{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption optional;
  inherit (lib.types)
    path
    bool
    listOf
    str
    port
    ;
  cfg = config.services.darkhttpd;

  args = lib.concatStringsSep " " (
    [
      cfg.rootDir
      "--port ${toString cfg.port}"
      "--addr ${cfg.address}"
    ]
    ++ cfg.extraArgs
    ++ optional cfg.hideServerId "--no-server-id"
    ++ optional config.networking.enableIPv6 "--ipv6"
  );

in
{
  options.services.darkhttpd = {
    enable = lib.mkEnableOption "DarkHTTPd web server";

    address = mkOption {
      default = "127.0.0.1";

      description = ''
        Address to listen on.
        Pass `all` to listen on all interfaces.
      '';

      type = str;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Additional configuration passed to the executable.
      '';

      type = listOf str;
    };

    hideServerId = mkOption {
      default = true;

      description = ''
        Don't identify the server type in headers or directory listings.
      '';

      type = bool;
    };

    port = mkOption {
      default = 80;

      description = ''
        Port to listen on.
        Pass 0 to let the system choose any free port for you.
      '';

      type = port;
    };

    rootDir = mkOption {
      description = ''
        Path from which to serve files.
      '';

      type = path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.darkhttpd = {
      after = [ "network.target" ];
      description = "Dark HTTPd";

      serviceConfig = {
        AmbientCapabilities = lib.mkIf (cfg.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        ExecStart = "${pkgs.darkhttpd}/bin/darkhttpd ${args}";
        Restart = "on-failure";
        RestartSec = "2s";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };
}

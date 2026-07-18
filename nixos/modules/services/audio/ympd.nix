{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ympd;
in
{

  ###### interface

  options = {

    services.ympd = {

      enable = lib.mkEnableOption "ympd, the MPD Web GUI";

      mpd = {
        host = lib.mkOption {
          default = "localhost";
          description = "The host where MPD is listening.";
          type = lib.types.str;
        };

        port = lib.mkOption {
          default = config.services.mpd.settings.port;
          defaultText = lib.literalExpression "config.services.mpd.settings.port";
          description = "The port where MPD is listening.";
          example = 6600;
          type = lib.types.port;
        };
      };

      webPort = lib.mkOption {
        default = "8080";
        description = "The port where ympd's web interface will be available.";
        example = "ssl://8080:/path/to/ssl-private-key.pem";
        type = lib.types.either lib.types.str lib.types.port; # string for backwards compat
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.ympd = {
      after = [ "network-online.target" ];
      description = "Standalone MPD Web GUI written in C";

      serviceConfig = {
        DynamicUser = true;

        ExecStart = ''
          ${pkgs.ympd}/bin/ympd \
            --host ${cfg.mpd.host} \
            --port ${toString cfg.mpd.port} \
            --webport ${toString cfg.webPort}
        '';

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "tmpfs";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service"
          "~@process"
          "~@setuid"
        ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

  };

}

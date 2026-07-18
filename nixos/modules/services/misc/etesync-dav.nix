{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.etesync-dav;
in
{
  options.services.etesync-dav = {
    enable = lib.mkEnableOption "etesync-dav, end-to-end encrypted sync for contacts, calendars and tasks";

    apiUrl = lib.mkOption {
      default = "https://api.etebase.com/partner/etesync/";
      description = "The url to the etesync API.";
      type = lib.types.str;
    };

    host = lib.mkOption {
      default = "localhost";
      description = "The server host address.";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall for the specified port.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 37358;
      description = "The server host port.";
      type = lib.types.port;
    };

    sslCertificate = lib.mkOption {
      default = null;

      description = ''
        Path to server SSL certificate. It will be copied into
        etesync-dav's data directory.
      '';

      example = "/var/etesync.crt";
      type = lib.types.nullOr lib.types.path;
    };

    sslCertificateKey = lib.mkOption {
      default = null;

      description = ''
        Path to server SSL certificate key.  It will be copied into
        etesync-dav's data directory.
      '';

      example = "/var/etesync.key";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.etesync-dav = {
      after = [ "network-online.target" ];
      description = "etesync-dav - A CalDAV and CardDAV adapter for EteSync";

      environment = {
        ETESYNC_DATA_DIR = "/var/lib/etesync-dav";
        ETESYNC_LISTEN_ADDRESS = cfg.host;
        ETESYNC_LISTEN_PORT = toString cfg.port;
        ETESYNC_URL = cfg.apiUrl;
      };

      path = [ pkgs.etesync-dav ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.etesync-dav}/bin/etesync-dav";

        ExecStartPre = lib.mkIf (cfg.sslCertificate != null || cfg.sslCertificateKey != null) (
          pkgs.writers.writeBash "etesync-dav-copy-keys" ''
            ${lib.optionalString (cfg.sslCertificate != null) ''
              cp ${toString cfg.sslCertificate} $STATE_DIRECTORY/etesync.crt
            ''}
            ${lib.optionalString (cfg.sslCertificateKey != null) ''
              cp ${toString cfg.sslCertificateKey} $STATE_DIRECTORY/etesync.key
            ''}
          ''
        );

        Restart = "on-failure";
        RestartSec = "30min 1s";
        StateDirectory = "etesync-dav";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}

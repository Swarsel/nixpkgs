{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.deluge;
  inherit (lib) mkOption types;
in
{
  extraOpts = {
    delugeHost = mkOption {
      default = "localhost";

      description = ''
        Hostname where deluge server is running.
      '';

      type = types.str;
    };

    delugePassword = mkOption {
      default = null;

      description = ''
        Password to connect to deluge server.

        This stores the password unencrypted in the nix store and is thus considered unsafe. Prefer
        using the delugePasswordFile option.
      '';

      type = types.nullOr types.str;
    };

    delugePasswordFile = mkOption {
      default = null;

      description = ''
        File containing the password to connect to deluge server.
      '';

      type = types.nullOr types.path;
    };

    delugePort = mkOption {
      default = 58846;

      description = ''
        Port where deluge server is listening.
      '';

      type = types.port;
    };

    delugeUser = mkOption {
      default = "localclient";

      description = ''
        User to connect to deluge server.
      '';

      type = types.str;
    };

    exportPerTorrentMetrics = mkOption {
      default = false;

      description = ''
        Enable per-torrent metrics.

        This may significantly increase the number of time series depending on the number of
        torrents in your Deluge instance.
      '';

      type = types.bool;
    };
  };

  port = 9354;

  serviceOpts = {
    script = ''
      passwordfile="$CREDENTIALS_DIRECTORY/password-file"
      if [ -e "$passwordfile" ]; then
        export DELUGE_PASSWORD="$(cat "$passwordfile")"
      fi

      exec ${pkgs.prometheus-deluge-exporter}/bin/deluge-exporter
    '';

    serviceConfig = {
      Environment = [
        "LISTEN_PORT=${toString cfg.port}"
        "LISTEN_ADDRESS=${toString cfg.listenAddress}"

        "DELUGE_HOST=${cfg.delugeHost}"
        "DELUGE_USER=${cfg.delugeUser}"
        "DELUGE_PORT=${toString cfg.delugePort}"
      ]
      ++ lib.optionals (cfg.delugePassword != null) [
        "DELUGE_PASSWORD=${cfg.delugePassword}"
      ]
      ++ lib.optionals cfg.exportPerTorrentMetrics [
        "PER_TORRENT_METRICS=1"
      ];

      LoadCredential = lib.mkIf (config.services.prometheus.exporters.deluge.delugePasswordFile != null) [
        "password-file:${config.services.prometheus.exporters.deluge.delugePasswordFile}"
      ];
    };
  };
}

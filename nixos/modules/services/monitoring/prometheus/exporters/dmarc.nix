{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.dmarc;
  inherit (lib) mkOption types optionalString;

  json = builtins.toJSON {
    inherit (cfg) folders port;
    deduplication_max_seconds = cfg.deduplicationMaxSeconds;

    imap = (removeAttrs cfg.imap [ "passwordFile" ]) // {
      password = "$IMAP_PASSWORD";
      use_ssl = true;
    };

    listen_addr = cfg.listenAddress;

    logging = {
      disable_existing_loggers = false;
      version = 1;
    };

    poll_interval_seconds = cfg.pollIntervalSeconds;
    storage_path = "$STATE_DIRECTORY";
  };
in
{
  extraOpts = {
    debug = mkOption {
      default = false;

      description = ''
        Whether to declare enable `--debug`.
      '';

      type = types.bool;
    };

    deduplicationMaxSeconds = mkOption {
      default = 604800;
      defaultText = "7 days (in seconds)";

      description = ''
        How long individual report IDs will be remembered to avoid
        counting double delivered reports twice.
      '';

      type = types.ints.unsigned;
    };

    folders = {
      done = mkOption {
        default = "Archive";

        description = ''
          IMAP mailbox that successfully processed reports are moved to.
        '';

        type = types.str;
      };

      error = mkOption {
        default = "Invalid";

        description = ''
          IMAP mailbox that emails are moved to that could not be processed.
        '';

        type = types.str;
      };

      inbox = mkOption {
        default = "INBOX";

        description = ''
          IMAP mailbox that is checked for incoming DMARC aggregate reports
        '';

        type = types.str;
      };
    };

    imap = {
      host = mkOption {
        default = "localhost";

        description = ''
          Hostname of IMAP server to connect to.
        '';

        type = types.str;
      };

      passwordFile = mkOption {
        description = ''
          File containing the login password for the IMAP connection.
        '';

        example = "/run/secrets/dovecot_pw";
        type = types.str;
      };

      port = mkOption {
        default = 993;

        description = ''
          Port of the IMAP server to connect to.
        '';

        type = types.port;
      };

      username = mkOption {
        description = ''
          Login username for the IMAP connection.
        '';

        example = "postmaster@example.org";
        type = types.str;
      };
    };

    pollIntervalSeconds = mkOption {
      default = 60;

      description = ''
        How often to poll the IMAP server in seconds.
      '';

      type = types.ints.unsigned;
    };
  };

  port = 9797;

  serviceOpts = {
    path = with pkgs; [
      envsubst
      coreutils
    ];

    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "setup-cfg" ''
        export IMAP_PASSWORD="$(<${cfg.imap.passwordFile})"
        envsubst \
          -i ${pkgs.writeText "dmarc-exporter.json.template" json} \
          -o ''${STATE_DIRECTORY}/dmarc-exporter.json

        exec ${pkgs.dmarc-metrics-exporter}/bin/dmarc-metrics-exporter \
          --configuration /var/lib/prometheus-dmarc-exporter/dmarc-exporter.json \
          ${optionalString cfg.debug "--debug"}
      ''}";

      StateDirectory = "prometheus-dmarc-exporter";
      WorkingDirectory = "/var/lib/prometheus-dmarc-exporter";
    };
  };
}

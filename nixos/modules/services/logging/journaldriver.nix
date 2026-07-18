# This module implements a systemd service for running journaldriver,
# a log forwarding agent that sends logs from journald to Stackdriver
# Logging.
#
# It can be enabled without extra configuration when running on GCP.
# On machines hosted elsewhere, the other configuration options need
# to be set.
#
# For further information please consult the documentation in the
# upstream repository at: https://github.com/tazjin/journaldriver/

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.journaldriver;
in
{
  options.services.journaldriver = {
    enable = mkOption {
      default = false;

      description = ''
        Whether to enable journaldriver to forward journald logs to
        Stackdriver Logging.
      '';

      type = types.bool;
    };

    applicationCredentials = mkOption {
      default = null;

      description = ''
        Path to the service account private key (in JSON-format) used
        to forward log entries to Stackdriver Logging on non-GCP
        instances.

        This option is required on non-GCP machines, but should not be
        set on GCP instances.
      '';

      type = with types; nullOr path;
    };

    googleCloudProject = mkOption {
      default = null;

      description = ''
        Configures the name of the Google Cloud project to which to
        forward journald logs.

        This option is required on non-GCP machines, but should not be
        set on GCP instances.
      '';

      type = with types; nullOr str;
    };

    logLevel = mkOption {
      default = "info";

      description = ''
        Log level at which journaldriver logs its own output.
      '';

      type = types.str;
    };

    logName = mkOption {
      default = null;

      description = ''
        Configures the name of the target log in Stackdriver Logging.
        This option can be set to, for example, the hostname of a
        machine to improve the user experience in the logging
        overview.
      '';

      type = with types; nullOr str;
    };

    logStream = mkOption {
      default = null;

      description = ''
        Configures the name of the Stackdriver Logging log stream into
        which to write journald entries.

        This option is required on non-GCP machines, but should not be
        set on GCP instances.
      '';

      type = with types; nullOr str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.journaldriver = {
      after = [ "network-online.target" ];
      description = "Stackdriver Logging journal forwarder";

      environment = {
        GOOGLE_APPLICATION_CREDENTIALS = cfg.applicationCredentials;
        GOOGLE_CLOUD_PROJECT = cfg.googleCloudProject;
        LOG_NAME = cfg.logName;
        LOG_STREAM = cfg.logStream;
        RUST_LOG = cfg.logLevel;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe pkgs.journaldriver;
        Restart = "always";
        # This directive lets systemd automatically configure
        # permissions on /var/lib/journaldriver, the directory in
        # which journaldriver persists its cursor state.
        StateDirectory = "journaldriver";
        # This group is required for accessing journald.
        SupplementaryGroups = "systemd-journal";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}

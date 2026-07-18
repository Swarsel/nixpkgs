{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lifecycled;

  # TODO: Add the ability to extend this with an rfc 42-like interface.
  # In the meantime, one can modify the environment (as
  # long as it's not overriding anything from here) with
  # systemd.services.lifecycled.serviceConfig.Environment
  configFile = pkgs.writeText "lifecycled" ''
    LIFECYCLED_HANDLER=${cfg.handler}
    ${lib.optionalString (
      cfg.cloudwatchGroup != null
    ) "LIFECYCLED_CLOUDWATCH_GROUP=${cfg.cloudwatchGroup}"}
    ${lib.optionalString (
      cfg.cloudwatchStream != null
    ) "LIFECYCLED_CLOUDWATCH_STREAM=${cfg.cloudwatchStream}"}
    ${lib.optionalString cfg.debug "LIFECYCLED_DEBUG=${lib.boolToString cfg.debug}"}
    ${lib.optionalString (cfg.instanceId != null) "LIFECYCLED_INSTANCE_ID=${cfg.instanceId}"}
    ${lib.optionalString cfg.json "LIFECYCLED_JSON=${lib.boolToString cfg.json}"}
    ${lib.optionalString cfg.noSpot "LIFECYCLED_NO_SPOT=${lib.boolToString cfg.noSpot}"}
    ${lib.optionalString (cfg.snsTopic != null) "LIFECYCLED_SNS_TOPIC=${cfg.snsTopic}"}
    ${lib.optionalString (cfg.awsRegion != null) "AWS_REGION=${cfg.awsRegion}"}
  '';
in
{
  options = {
    services.lifecycled = {
      enable = lib.mkEnableOption "lifecycled, a daemon for responding to AWS AutoScaling Lifecycle Hooks";

      # XXX: Can be removed if / when
      # https://github.com/buildkite/lifecycled/pull/91 is merged.
      awsRegion = lib.mkOption {
        default = null;

        description = ''
          The region used for accessing AWS services.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      cloudwatchGroup = lib.mkOption {
        default = null;

        description = ''
          Write logs to a specific Cloudwatch Logs group.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      cloudwatchStream = lib.mkOption {
        default = null;

        description = ''
          Write logs to a specific Cloudwatch Logs stream. Defaults to the instance ID.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      debug = lib.mkOption {
        default = false;

        description = ''
          Enable debugging information.
        '';

        type = lib.types.bool;
      };

      handler = lib.mkOption {
        description = ''
          The script to invoke to handle events.
        '';

        type = lib.types.path;
      };

      instanceId = lib.mkOption {
        default = null;

        description = ''
          The instance ID to listen for events for.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      json = lib.mkOption {
        default = false;

        description = ''
          Enable JSON logging.
        '';

        type = lib.types.bool;
      };

      noSpot = lib.mkOption {
        default = false;

        description = ''
          Disable the spot termination listener.
        '';

        type = lib.types.bool;
      };

      queueCleaner = {
        enable = lib.mkEnableOption "lifecycled-queue-cleaner";

        frequency = lib.mkOption {
          default = "hourly";

          description = ''
            How often to trigger the queue cleaner.

            NOTE: This string should be a valid value for a systemd
            timer's `OnCalendar` configuration. See
            {manpage}`systemd.timer(5)`
            for more information.
          '';

          type = lib.types.str;
        };

        parallel = lib.mkOption {
          default = 20;

          description = ''
            The number of parallel deletes to run.
          '';

          type = lib.types.ints.unsigned;
        };
      };

      snsTopic = lib.mkOption {
        default = null;

        description = ''
          The SNS topic that receives events.
        '';

        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  ### Implementation ###
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.etc."lifecycled".source = configFile;
      systemd.packages = [ pkgs.lifecycled ];

      systemd.services.lifecycled = {
        restartTriggers = [ configFile ];
        wantedBy = [ "network-online.target" ];
      };
    })

    (lib.mkIf cfg.queueCleaner.enable {
      systemd.services.lifecycled-queue-cleaner = {
        description = "Lifecycle Daemon Queue Cleaner";
        environment = lib.optionalAttrs (cfg.awsRegion != null) { AWS_REGION = cfg.awsRegion; };

        serviceConfig = {
          ExecStart = "${pkgs.lifecycled}/bin/lifecycled-queue-cleaner -parallel ${toString cfg.queueCleaner.parallel}";
          Type = "oneshot";
        };
      };

      systemd.timers.lifecycled-queue-cleaner = {
        after = [ "network-online.target" ];
        description = "Lifecycle Daemon Queue Cleaner Timer";

        timerConfig = {
          OnCalendar = "${cfg.queueCleaner.frequency}";
          Unit = "lifecycled-queue-cleaner.service";
        };

        wantedBy = [ "timers.target" ];
      };
    })
  ];

  meta.maintainers = with lib.maintainers; [
    cole-h
  ];
}

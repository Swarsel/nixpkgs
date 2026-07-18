{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.alertmanagerGotify;
  pkg = cfg.package;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    mkPackageOption
    optionalString
    ;
in
{
  options.services.prometheus.alertmanagerGotify = {
    enable = mkEnableOption "alertmagager-gotify";
    package = mkPackageOption pkgs "alertmanager-gotify-bridge" { };

    bindAddress = mkOption {
      default = "0.0.0.0";
      description = "The address the server will listen on (bind address).";
      type = types.str;
    };

    debug = mkOption {
      default = false;
      description = "Enables extended logs for debugging purposes. Should be disabled in productive mode.";
      type = types.bool;
    };

    defaultPriority = mkOption {
      default = 5;
      description = "The default priority for messages sent to gotify.";
      type = types.int;
    };

    dispatchErrors = mkOption {
      default = false;
      description = "When enabled, alerts will be tried to dispatch with an error message regarding faulty templating or missing fields to help debugging.";
      type = types.bool;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        File containing additional config environment variables for alertmanager-gotify-bridge.
        This is especially for secrets like GOTIFY_TOKEN and AUTH_PASSWORD.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    extendedDetails = mkOption {
      default = false;
      description = "When enabled, alerts are presented in HTML format and include colorized status (FIR|RES), alert start time, and a link to the generator of the alert.";
      type = types.bool;
    };

    gotifyEndpoint = {
      host = mkOption {
        default = "127.0.0.1";
        description = "The hostname or ip your gotify endpoint is running.";
        type = types.str;
      };

      port = mkOption {
        default = 443;
        description = "The port your gotify endpoint is running.";
        type = types.port;
      };

      tls = mkOption {
        default = true;
        description = "If your gotify endpoint uses https, leave this option set to default";
        type = types.bool;
      };
    };

    messageAnnotation = mkOption {
      description = "Annotation holding the alert message.";
      type = types.str;
    };

    metrics = {
      namespace = mkOption {
        default = "alertmanager-gotify-bridge";
        description = "The namescape of the metrics.";
        type = types.str;
      };

      path = mkOption {
        default = "/metrics";
        description = "The path under which the metrics will be exposed.";
        type = types.str;
      };

      username = mkOption {
        description = "The username used to access your metrics.";
        type = types.str;
      };
    };

    openFirewall = mkOption {
      default = false;
      description = "Opens the bridge port in the firewall.";
      type = types.bool;
    };

    port = mkOption {
      default = 8080;
      description = "The local port the bridge is listening on.";
      type = types.port;
    };

    priorityAnnotation = mkOption {
      default = "priority";
      description = "Annotation holding the priority of the alert.";
      type = types.str;
    };

    timeout = mkOption {
      default = 5;
      description = "The time between sending a message and the timeout.";
      type = types.ints.positive;
    };

    titleAnnotation = mkOption {
      default = "summary";
      description = "Annotation holding the title of the alert";
      type = types.str;
    };

    webhookPath = mkOption {
      default = "/gotify_webhook";
      description = "The URL path to handle requests on.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.alertmanager-gotify-bridge = {
      description = "A bridge between Prometheus AlertManager and a Gotify server";

      environment = {
        AUTH_USERNAME = cfg.metrics.username;
        BIND_ADDRESS = cfg.bindAddress;
        DEFAULT_PRIORITY = toString cfg.defaultPriority;
        DISPATCH_ERRORS = toString cfg.dispatchErrors;
        EXTENDED_DETAILS = toString cfg.extendedDetails;

        GOTIFY_ENDPOINT = "${
          if cfg.gotifyEndpoint.tls then "https://" else "http://"
        }${toString cfg.gotifyEndpoint.host}:${toString cfg.gotifyEndpoint.port}/message";

        MESSAGE_ANNOTATION = cfg.messageAnnotation;
        PORT = toString cfg.port;
        PRIORITY_ANNOTATION = cfg.priorityAnnotation;
        TIMEOUT = "${toString cfg.timeout}s";
        TITLE_ANNOTATION = cfg.titleAnnotation;
        WEBHOOK_PATH = cfg.webhookPath;
      };

      serviceConfig = {
        DevicePolicy = "closed";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${lib.getExe pkg} ${optionalString cfg.debug "--debug"}";
        Group = "alertmanager-gotify";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        #hardening
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = true;
        ProtectSystem = "strict";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        User = "alertmanager-gotify";

      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.alertmanager-gotify = { };

      users.alertmanager-gotify = {
        group = "alertmanager-gotify";
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ juli0604 ];
}

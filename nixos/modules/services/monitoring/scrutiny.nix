{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    ;
  inherit (lib.types)
    bool
    enum
    nullOr
    port
    str
    submodule
    ;
  inherit (utils) genJqSecretsReplacementSnippet;

  cfg = config.services.scrutiny;
  # Define the settings format used for this program
  settingsFormat = pkgs.formats.yaml { };
in
{
  options = {
    services.scrutiny = {
      enable = mkEnableOption "Scrutiny, a web application for drive monitoring";
      package = mkPackageOption pkgs "scrutiny" { };

      collector = {
        enable = mkEnableOption "the Scrutiny metrics collector" // {
          default = cfg.enable;
          defaultText = lib.literalExpression "config.services.scrutiny.enable";
        };

        package = mkPackageOption pkgs "scrutiny-collector" { };

        schedule = mkOption {
          default = "daily";

          description = ''
            How often to run the collector in systemd calendar format.
          '';

          type = str;
        };

        settings = mkOption {
          default = { };

          description = ''
            Collector settings to be rendered into the collector configuration file.

            See <https://github.com/AnalogJ/scrutiny/blob/master/example.collector.yaml>.

            Options containing secret data should be set to an attribute set
            containing the attribute `_secret`. This attribute should be a string
            or structured JSON with `quote = false;`, pointing to a file that
            contains the value the option should be set to.
          '';

          type = submodule {
            options.api.endpoint = mkOption {
              default = "http://${cfg.settings.web.listen.host}:${toString cfg.settings.web.listen.port}${cfg.settings.web.listen.basepath}";
              defaultText = literalExpression ''"http://''${config.services.scrutiny.settings.web.listen.host}:''${config.services.scrutiny.settings.web.listen.port}''${config.services.scrutiny.settings.web.listen.basepath}"'';
              description = "Scrutiny app API endpoint for sending metrics to.";
              type = str;
            };

            options.host.id = mkOption {
              default = null;
              description = "Host ID for identifying/labelling groups of disks";
              type = nullOr str;
            };

            options.log.level = mkOption {
              default = "INFO";
              description = "Log level for Scrutiny collector.";

              type = enum [
                "INFO"
                "DEBUG"
              ];
            };

            freeformType = settingsFormat.type;
          };
        };
      };

      influxdb.enable = mkOption {
        default = true;

        description = ''
          Enables InfluxDB on the host system using the `services.influxdb2` NixOS module
          with default options.

          If you already have InfluxDB configured, or wish to connect to an external InfluxDB
          instance, disable this option.
        '';

        type = bool;
      };

      openFirewall = mkEnableOption "opening the default ports in the firewall for Scrutiny";

      settings = mkOption {
        default = { };

        description = ''
          Scrutiny settings to be rendered into the configuration file.

          See <https://github.com/AnalogJ/scrutiny/blob/master/example.scrutiny.yaml>.

          Options containing secret data should be set to an attribute set
          containing the attribute `_secret`. This attribute should be a string
          or structured JSON with `quote = false;`, pointing to a file that
          contains the value the option should be set to.
        '';

        type = submodule {
          options.log.level = mkOption {
            default = "INFO";
            description = "Log level for Scrutiny.";

            type = enum [
              "INFO"
              "DEBUG"
            ];
          };

          options.web.influxdb.bucket = mkOption {
            default = null;
            description = "InfluxDB bucket in which to store data.";
            type = nullOr str;
          };

          options.web.influxdb.host = mkOption {
            default = "0.0.0.0";
            description = "IP or hostname of the InfluxDB instance.";
            type = str;
          };

          options.web.influxdb.org = mkOption {
            default = null;
            description = "InfluxDB organisation under which to store data.";
            type = nullOr str;
          };

          options.web.influxdb.port = mkOption {
            default = 8086;
            description = "The port of the InfluxDB instance.";
            type = port;
          };

          options.web.influxdb.scheme = mkOption {
            default = "http";
            description = "URL scheme to use when connecting to InfluxDB.";
            type = str;
          };

          options.web.influxdb.tls.insecure_skip_verify =
            mkEnableOption "skipping TLS verification when connecting to InfluxDB";

          options.web.influxdb.token = mkOption {
            default = null;
            description = "Authentication token for connecting to InfluxDB.";
            type = nullOr str;
          };

          options.web.listen.basepath = mkOption {
            default = "";

            description = ''
              If Scrutiny will be behind a path prefixed reverse proxy, you can override this
              value to serve Scrutiny on a subpath.
            '';

            example = "/scrutiny";
            type = str;
          };

          options.web.listen.host = mkOption {
            default = "0.0.0.0";
            description = "Interface address for web application to bind to.";
            type = str;
          };

          options.web.listen.port = mkOption {
            default = 8080;
            description = "Port for web application to listen on.";
            type = port;
          };

          freeformType = settingsFormat.type;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      networking.firewall = mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.settings.web.listen.port ];
      };

      services.influxdb2.enable = cfg.influxdb.enable;

      systemd.services.scrutiny = {
        after = [ "network.target" ] ++ lib.optional cfg.influxdb.enable "influxdb2.service";
        description = "Hard Drive S.M.A.R.T Monitoring, Historical Trends & Real World Failure Thresholds";
        enableStrictShellChecks = true;

        environment = {
          SCRUTINY_VERSION = "1";
          SCRUTINY_WEB_DATABASE_LOCATION = "/var/lib/scrutiny/scrutiny.db";
          SCRUTINY_WEB_SRC_FRONTEND_PATH = "${cfg.package}/share/scrutiny";
        };

        postStart = ''
          for _ in $(seq 300); do
              if "${lib.getExe pkgs.curl}" --fail --silent --head "http://${cfg.settings.web.listen.host}:${toString cfg.settings.web.listen.port}" >/dev/null; then
                  echo "Scrutiny is ready (port is open)"
                  exit 0
              fi
              echo "Waiting for Scrutiny to open port..."
              sleep 0.2
          done
          echo "Timeout waiting for Scrutiny to open port" >&2
          exit 1
        '';

        preStart = ''
          ${genJqSecretsReplacementSnippet cfg.settings "/run/scrutiny/config.yaml"}
        '';

        serviceConfig = {
          CapabilityBoundingSet = "";
          DynamicUser = true;
          ExecStart = "${getExe cfg.package} start --config /run/scrutiny/config.yaml";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_NETLINK"
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "scrutiny";
          RuntimeDirectoryMode = "0700";

          SocketBindAllow = [
            "tcp:${toString cfg.settings.web.listen.port}"
          ];

          SocketBindDeny = "any";
          StateDirectory = "scrutiny";
          StateDirectoryMode = "0750";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];
        };

        wantedBy = [ "multi-user.target" ];
        wants = lib.optional cfg.influxdb.enable "influxdb2.service";
      };
    })
    (mkIf cfg.collector.enable {
      services.smartd = {
        enable = true;

        extraOptions = [
          "-A /var/log/smartd/"
          "--interval=600"
        ];
      };

      systemd = {
        services.scrutiny-collector = {
          after = lib.optional cfg.enable "scrutiny.service";
          description = "Scrutiny Collector Service";
          enableStrictShellChecks = true;

          environment = {
            COLLECTOR_API_ENDPOINT = cfg.collector.settings.api.endpoint;
            COLLECTOR_VERSION = "1";
          };

          preStart = ''
            ${genJqSecretsReplacementSnippet cfg.collector.settings "/run/scrutiny-collector/config.yaml"}
          '';

          serviceConfig = {
            ExecStart = "${getExe cfg.collector.package} run --config /run/scrutiny-collector/config.yaml";
            RuntimeDirectory = "scrutiny-collector";
            RuntimeDirectoryMode = "0700";
            Type = "oneshot";
          };

          startAt = cfg.collector.schedule;
          wants = lib.optional cfg.enable "scrutiny.service";
        };

        timers.scrutiny-collector.timerConfig.Persistent = true;
      };
    })
  ];

  meta.maintainers = [ ];
}

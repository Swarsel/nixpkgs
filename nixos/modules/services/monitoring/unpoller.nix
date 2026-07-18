{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.unpoller;

  configFile = pkgs.writeText "unpoller.json" (
    lib.generators.toJSON { } {
      inherit (cfg)
        poller
        influxdb
        loki
        prometheus
        unifi
        ;
    }
  );

in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "unifi-poller" ] [ "services" "unpoller" ])
  ];

  options.services.unpoller = {
    enable = lib.mkEnableOption "unpoller";

    influxdb = {
      db = lib.mkOption {
        default = "unifi";

        description = ''
          Database name. Database should exist.
        '';

        type = lib.types.str;
      };

      disable = lib.mkOption {
        default = false;

        description = ''
          Whether to disable the influxdb output plugin.
        '';

        type = lib.types.bool;
      };

      interval = lib.mkOption {
        default = "30s";

        description = ''
          Setting this lower than the Unifi controller's refresh
          interval may lead to zeroes in your database.
        '';

        type = lib.types.str;
      };

      pass = lib.mkOption {
        apply = v: "file://${v}";
        default = pkgs.writeText "unpoller-influxdb-default.password" "unifipoller";
        defaultText = lib.literalExpression "unpoller-influxdb-default.password";

        description = ''
          Path of a file containing the password for influxdb.
          This file needs to be readable by the unifi-poller user.
        '';

        type = lib.types.path;
      };

      url = lib.mkOption {
        default = "http://127.0.0.1:8086";

        description = ''
          URL of the influxdb host.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "unifipoller";

        description = ''
          Username for the influxdb.
        '';

        type = lib.types.str;
      };

      verify_ssl = lib.mkOption {
        default = true;

        description = ''
          Verify the influxdb's certificate.
        '';

        type = lib.types.bool;
      };
    };

    loki = {
      interval = lib.mkOption {
        default = "2m";

        description = ''
          How often the events are polled and pushed to Loki.
        '';

        type = lib.types.str;
      };

      pass = lib.mkOption {
        apply = v: "file://${v}";
        default = pkgs.writeText "unpoller-loki-default.password" "";
        defaultText = "unpoller-influxdb-default.password";

        description = ''
          Path of a file containing the password for Loki.
          This file needs to be readable by the unifi-poller user.
        '';

        type = lib.types.path;
      };

      tenant_id = lib.mkOption {
        default = "";

        description = ''
          Tenant ID to use in Loki.
        '';

        type = lib.types.str;
      };

      timeout = lib.mkOption {
        default = "10s";

        description = ''
          Should be increased in case of timeout errors.
        '';

        type = lib.types.str;
      };

      url = lib.mkOption {
        default = "";

        description = ''
          URL of the Loki host.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "";

        description = ''
          Username for Loki.
        '';

        type = lib.types.str;
      };

      verify_ssl = lib.mkOption {
        default = false;

        description = ''
          Verify Loki's certificate.
        '';

        type = lib.types.bool;
      };
    };

    poller = {
      debug = lib.mkOption {
        default = false;

        description = ''
          Turns on line numbers, microsecond logging, and a per-device log.
          This may be noisy if you have a lot of devices. It adds one line per device.
        '';

        type = lib.types.bool;
      };

      plugins = lib.mkOption {
        default = [ ];

        description = ''
          Load additional plugins.
        '';

        type = with lib.types; listOf str;
      };

      quiet = lib.mkOption {
        default = false;

        description = ''
          Turns off per-interval logs. Only startup and error logs will be emitted.
        '';

        type = lib.types.bool;
      };
    };

    prometheus = {
      disable = lib.mkOption {
        default = false;

        description = ''
          Whether to disable the prometheus output plugin.
        '';

        type = lib.types.bool;
      };

      http_listen = lib.mkOption {
        default = "[::]:9130";

        description = ''
          Bind the prometheus exporter to this IP or hostname.
        '';

        type = lib.types.str;
      };

      report_errors = lib.mkOption {
        default = false;

        description = ''
          Whether to report errors.
        '';

        type = lib.types.bool;
      };
    };

    unifi =
      let
        controllerOptions = {
          hash_pii = lib.mkOption {
            default = false;

            description = ''
              Hash, with md5, client names and MAC addresses. This attempts
              to protect personally identifiable information.
            '';

            type = lib.types.bool;
          };

          pass = lib.mkOption {
            apply = v: "file://${v}";
            default = pkgs.writeText "unpoller-unifi-default.password" "unifi";
            defaultText = lib.literalExpression "unpoller-unifi-default.password";

            description = ''
              Path of a file containing the password for the unifi service user.
              This file needs to be readable by the unifi-poller user.
            '';

            type = lib.types.path;
          };

          save_alarms = lib.mkOption {
            default = false;

            description = ''
              Collect and save data from UniFi alarms to influxdb and Loki.
            '';

            type = lib.types.bool;
          };

          save_anomalies = lib.mkOption {
            default = false;

            description = ''
              Collect and save data from UniFi anomalies to influxdb and Loki.
            '';

            type = lib.types.bool;
          };

          save_dpi = lib.mkOption {
            default = false;

            description = ''
              Collect and save data from deep packet inspection.
              Adds around 150 data points and impacts performance.
            '';

            type = lib.types.bool;
          };

          save_events = lib.mkOption {
            default = false;

            description = ''
              Collect and save data from UniFi events to influxdb and Loki.
            '';

            type = lib.types.bool;
          };

          save_ids = lib.mkOption {
            default = false;

            description = ''
              Collect and save data from the intrusion detection system to influxdb and Loki.
            '';

            type = lib.types.bool;
          };

          save_sites = lib.mkOption {
            default = true;

            description = ''
              Collect and save site data.
            '';

            type = lib.types.bool;
          };

          sites = lib.mkOption {
            apply = lib.toList;
            default = "all";

            description = ''
              List of site names for which statistics should be exported.
              Or the string "default" for the default site or the string "all" for all sites.
            '';

            type =
              with lib.types;
              either (enum [
                "default"
                "all"
              ]) (listOf str);
          };

          url = lib.mkOption {
            default = "https://unifi:8443";

            description = ''
              URL of the Unifi controller.
            '';

            type = lib.types.str;
          };

          user = lib.mkOption {
            default = "unifi";

            description = ''
              Unifi service user name.
            '';

            type = lib.types.str;
          };

          verify_ssl = lib.mkOption {
            default = true;

            description = ''
              Verify the Unifi controller's certificate.
            '';

            type = lib.types.bool;
          };
        };

      in
      {
        controllers = lib.mkOption {
          apply = map (lib.flip removeAttrs [ "_module" ]);
          default = [ ];

          description = ''
            List of Unifi controllers to poll. Use defaults if empty.
          '';

          type =
            with lib.types;
            listOf (submodule {
              options = controllerOptions;
            });
        };

        defaults = controllerOptions;

        dynamic = lib.mkOption {
          default = false;

          description = ''
            Let prometheus select which controller to poll when scraping.
            Use with default credentials. See unifi-poller wiki for more.
          '';

          type = lib.types.bool;
        };
      };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.unifi-poller = {
      after = [ "network.target" ];

      serviceConfig = {
        DevicePolicy = "closed";
        ExecStart = "${pkgs.unpoller}/bin/unpoller --config ${configFile}";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "full";
        Restart = "always";
        User = "unifi-poller";
        WorkingDirectory = "/tmp";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.unifi-poller = { };

    users.users.unifi-poller = {
      description = "unifi-poller Service User";
      group = "unifi-poller";
      isSystemUser = true;
    };
  };
}

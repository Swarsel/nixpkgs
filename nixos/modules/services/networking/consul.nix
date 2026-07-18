{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let

  dataDir = "/var/lib/consul";
  cfg = config.services.consul;

  configOptions = {
    data_dir = dataDir;

    ui_config = {
      enabled = cfg.webUi;
    };
  }
  // cfg.extraConfig;

  configFiles = [
    "/etc/consul.json"
    "/etc/consul-addrs.json"
  ]
  ++ cfg.extraConfigFiles;

  devices = lib.attrValues (lib.filterAttrs (_: i: i != null) cfg.interface);
  systemdDevices = lib.forEach devices (
    i: "sys-subsystem-net-devices-${utils.escapeSystemdPath i}.device"
  );
in
{
  options = {

    services.consul = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Enables the consul daemon.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "consul" { };

      alerts = {
        enable = lib.mkEnableOption "consul-alerts";
        package = lib.mkPackageOption pkgs "consul-alerts" { };

        consulAddr = lib.mkOption {
          default = "localhost:8500";
          description = "Consul api listening address";
          type = lib.types.str;
        };

        listenAddr = lib.mkOption {
          default = "localhost:9000";
          description = "Api listening address.";
          type = lib.types.str;
        };

        watchChecks = lib.mkOption {
          default = true;
          description = "Whether to enable check watcher.";
          type = lib.types.bool;
        };

        watchEvents = lib.mkOption {
          default = true;
          description = "Whether to enable event watcher.";
          type = lib.types.bool;
        };
      };

      dropPrivileges = lib.mkOption {
        default = true;

        description = ''
          Whether the consul agent should be run as a non-root consul user.
        '';

        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = { };

        description = ''
          Extra configuration options which are serialized to json and added
          to the config.json file.
        '';

        type = lib.types.attrsOf lib.types.anything;
      };

      extraConfigFiles = lib.mkOption {
        default = [ ];

        description = ''
          Additional configuration files to pass to consul
          NOTE: These will not trigger the service to be restarted when altered.
        '';

        type = lib.types.listOf lib.types.str;
      };

      forceAddrFamily = lib.mkOption {
        default = "any";

        description = ''
          Whether to bind ipv4/ipv6 or both kind of addresses.
        '';

        type = lib.types.enum [
          "any"
          "ipv4"
          "ipv6"
        ];
      };

      forceIpv4 = lib.mkOption {
        default = null;

        description = ''
          Deprecated: Use consul.forceAddrFamily instead.
          Whether we should force the interfaces to only pull ipv4 addresses.
        '';

        type = lib.types.nullOr lib.types.bool;
      };

      interface = {

        advertise = lib.mkOption {
          default = null;

          description = ''
            The name of the interface to pull the advertise_addr from.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        bind = lib.mkOption {
          default = null;

          description = ''
            The name of the interface to pull the bind_addr from.
          '';

          type = lib.types.nullOr lib.types.str;
        };
      };

      leaveOnStop = lib.mkOption {
        default = false;

        description = ''
          If enabled, causes a leave action to be sent when closing consul.
          This allows a clean termination of the node, but permanently removes
          it from the cluster. You probably don't want this option unless you
          are running a node which going offline in a permanent / semi-permanent
          fashion.
        '';

        type = lib.types.bool;
      };

      webUi = lib.mkOption {
        default = false;

        description = ''
          Enables the web interface on the consul http port.
        '';

        type = lib.types.bool;
      };

    };

  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {

        environment = {
          # We need consul.d to exist for consul to start
          etc."consul.d/dummy.json".text = "{ }";
          etc."consul.json".text = builtins.toJSON configOptions;
          systemPackages = [ cfg.package ];
        };

        systemd.services.consul = {
          after = [ "network.target" ] ++ systemdDevices;
          bindsTo = systemdDevices;

          path = with pkgs; [
            iproute2
            gawk
            cfg.package
          ];

          preStart =
            let
              family =
                if cfg.forceAddrFamily == "ipv6" then
                  "-6"
                else if cfg.forceAddrFamily == "ipv4" then
                  "-4"
                else
                  "";
            in
            ''
              mkdir -m 0700 -p ${dataDir}
              chown -R consul ${dataDir}

              # Determine interface addresses
              getAddrOnce () {
                ip ${family} addr show dev "$1" scope global \
                  | awk -F '[ /\t]*' '/inet/ {print $3}' | head -n 1
              }
              getAddr () {
                ADDR="$(getAddrOnce $1)"
                LEFT=60 # Die after 1 minute
                while [ -z "$ADDR" ]; do
                  sleep 1
                  LEFT=$(expr $LEFT - 1)
                  if [ "$LEFT" -eq "0" ]; then
                    echo "Address lookup timed out"
                    exit 1
                  fi
                  ADDR="$(getAddrOnce $1)"
                done
                echo "$ADDR"
              }
              echo "{" > /etc/consul-addrs.json
              delim=" "
            ''
            + lib.concatStrings (
              lib.flip lib.mapAttrsToList cfg.interface (
                name: i:
                lib.optionalString (i != null) ''
                  echo "$delim \"${name}_addr\": \"$(getAddr "${i}")\"" >> /etc/consul-addrs.json
                  delim=","
                ''
              )
            )
            + ''
              echo "}" >> /etc/consul-addrs.json
            '';

          restartTriggers = [
            config.environment.etc."consul.json".source
          ]
          ++ lib.mapAttrsToList (_: d: d.source) (
            lib.filterAttrs (n: _: lib.hasPrefix "consul.d/" n) config.environment.etc
          );

          serviceConfig = {
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

            ExecStart =
              "@${lib.getExe cfg.package} consul agent -config-dir /etc/consul.d"
              + lib.concatMapStrings (n: " -config-file ${n}") configFiles;

            PermissionsStartOnly = true;
            Restart = "on-failure";
            TimeoutStartSec = "infinity";
            User = if cfg.dropPrivileges then "consul" else null;
          }
          // (lib.optionalAttrs (cfg.leaveOnStop) {
            ExecStop = "${lib.getExe cfg.package} leave";
          });

          wantedBy = [ "multi-user.target" ];
        };

        users.groups.consul = { };

        users.users.consul = {
          description = "Consul agent daemon user";
          group = "consul";
          isSystemUser = true;
          # The shell is needed for health checks
          shell = "/run/current-system/sw/bin/bash";
        };

        warnings = lib.flatten [
          (lib.optional (cfg.forceIpv4 != null) ''
            The option consul.forceIpv4 is deprecated, please use
            consul.forceAddrFamily instead.
          '')
        ];
      }

      # deprecated
      (lib.mkIf (cfg.forceIpv4 != null && cfg.forceIpv4) {
        services.consul.forceAddrFamily = "ipv4";
      })

      (lib.mkIf (cfg.alerts.enable) {
        systemd.services.consul-alerts = {
          after = [ "consul.service" ];
          path = [ cfg.package ];

          serviceConfig = {
            ExecStart = ''
              ${lib.getExe cfg.alerts.package} start \
                --alert-addr=${cfg.alerts.listenAddr} \
                --consul-addr=${cfg.alerts.consulAddr} \
                ${lib.optionalString cfg.alerts.watchChecks "--watch-checks"} \
                ${lib.optionalString cfg.alerts.watchEvents "--watch-events"}
            '';

            Restart = "on-failure";
            User = if cfg.dropPrivileges then "consul" else null;
          };

          wantedBy = [ "multi-user.target" ];
        };
      })

    ]
  );
}

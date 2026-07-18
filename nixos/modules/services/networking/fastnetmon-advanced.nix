{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Background information: FastNetMon requires a MongoDB to start. This is because
  # it uses MongoDB to store its configuration. That is, in a normal setup there is
  # one collection with one document.
  # To provide declarative configuration in our NixOS module, this database is
  # completely emptied and replaced on each boot by the fastnetmon-setup service
  # using the configuration backup functionality.

  cfg = config.services.fastnetmon-advanced;
  settingsFormat = pkgs.formats.yaml { };

  # obtain the default configs by starting up ferretdb and fcli in a derivation
  default_configs =
    pkgs.runCommand "default-configs"
      {
        nativeBuildInputs = [
          pkgs.ferretdb
          pkgs.fastnetmon-advanced # for fcli
          pkgs.proot
        ];
      }
      ''
        mkdir ferretdb fastnetmon $out
        FERRETDB_TELEMETRY="disable" FERRETDB_HANDLER="sqlite" FERRETDB_STATE_DIR="$PWD/ferretdb" FERRETDB_SQLITE_URL="file:$PWD/ferretdb/" ferretdb &

        cat << EOF > fastnetmon/fastnetmon.conf
        ${builtins.toJSON {
          mongodb_username = "";
        }}
        EOF
        proot -b fastnetmon:/etc/fastnetmon -0 fcli create_configuration
        proot -b fastnetmon:/etc/fastnetmon -0 fcli set bgp default
        proot -b fastnetmon:/etc/fastnetmon -0 fcli export_configuration backup.tar
        tar -C $out --no-same-owner -xvf backup.tar
      '';

  # merge the user configs into the default configs
  config_tar =
    pkgs.runCommand "fastnetmon-config.tar"
      {
        nativeBuildInputs = with pkgs; [ jq ];
      }
      ''
        jq -s add ${default_configs}/main.json ${pkgs.writeText "main-add.json" (builtins.toJSON cfg.settings)} > main.json
        mkdir hostgroup
        ${lib.concatImapStringsSep "\n" (pos: hostgroup: ''
          jq -s add ${default_configs}/hostgroup/0.json ${pkgs.writeText "hostgroup-${toString (pos - 1)}-add.json" (builtins.toJSON hostgroup)} > hostgroup/${toString (pos - 1)}.json
        '') hostgroups}
        mkdir bgp
        ${lib.concatImapStringsSep "\n" (pos: bgp: ''
          jq -s add ${default_configs}/bgp/0.json ${pkgs.writeText "bgp-${toString (pos - 1)}-add.json" (builtins.toJSON bgp)} > bgp/${toString (pos - 1)}.json
        '') bgpPeers}
        tar -cf $out main.json ${
          lib.concatImapStringsSep " " (pos: _: "hostgroup/${toString (pos - 1)}.json") hostgroups
        } ${lib.concatImapStringsSep " " (pos: _: "bgp/${toString (pos - 1)}.json") bgpPeers}
      '';

  hostgroups = lib.mapAttrsToList (name: hostgroup: { inherit name; } // hostgroup) cfg.hostgroups;
  bgpPeers = lib.mapAttrsToList (name: bgpPeer: { inherit name; } // bgpPeer) cfg.bgpPeers;

in
{
  options.services.fastnetmon-advanced = with lib; {
    enable = mkEnableOption "the fastnetmon-advanced DDoS Protection daemon";

    bgpPeers = mkOption {
      default = { };
      description = "BGP Peers to declaratively load into FastNetMon Advanced";
      type = types.attrsOf settingsFormat.type;
    };

    enableAdvancedTrafficPersistence = mkOption {
      default = false;
      description = "Store historical flow data in clickhouse";
      type = types.bool;
    };

    hostgroups = mkOption {
      default = { };
      description = "Hostgroups to declaratively load into FastNetMon Advanced";
      type = types.attrsOf settingsFormat.type;
    };

    settings = mkOption {
      default = { };

      description = ''
        Extra configuration options to declaratively load into FastNetMon Advanced.

        See the [FastNetMon Advanced Configuration options reference](https://fastnetmon.com/docs-fnm-advanced/fastnetmon-advanced-configuration-options/) for more details.
      '';

      example = literalExpression ''
        {
          networks_list = [ "192.0.2.0/24" ];
          gobgp = true;
          gobgp_flow_spec_announces = true;
        }
      '';

      type = settingsFormat.type;
    };

    traffic_db.settings = mkOption {
      description = "Additional settings for /etc/fastnetmon/traffic_db.conf";
      type = settingsFormat.type;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.etc."fastnetmon/fastnetmon.conf".source = pkgs.writeText "fastnetmon.conf" (
        builtins.toJSON {
          mongodb_username = "";
        }
      );

      environment.etc."fastnetmon/gobgpd.conf".source = "/run/fastnetmon/gobgpd.conf";
      environment.etc."fastnetmon/license.lic".source = "/var/lib/fastnetmon/license.lic";

      environment.systemPackages = with pkgs; [
        fastnetmon-advanced # for fcli
      ];

      security.polkit.enable = true;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.isInGroup("fastnetmon")) {
            if (action.lookup("unit") == "gobgp.service") {
              var verb = action.lookup("verb");
              if (verb == "start" || verb == "stop" || verb == "restart") {
                return polkit.Result.YES;
              }
            }
          }
        });
      '';

      # dbus/polkit with DynamicUser is broken with the default implementation
      services.dbus.implementation = "broker";

      services.fastnetmon-advanced.hostgroups = {
        global = { };
      };

      services.ferretdb.enable = true;

      systemd.services.fastnetmon = {
        after = [
          "ferretdb.service"
          "fastnetmon-setup.service"
          "polkit.service"
        ];

        path = with pkgs; [ iproute2 ];

        serviceConfig = {
          CacheDirectory = "fastnetmon";
          DynamicUser = true;
          ExecStart = "${pkgs.fastnetmon-advanced}/bin/fastnetmon --log_to_console";
          LimitNOFILE = 65535;
          # Restart service when it fails due to any reasons, we need to keep processing traffic no matter what happened
          Restart = "on-failure";
          RestartSec = "5s";
          RuntimeDirectory = "fastnetmon"; # for gobgpd config
          StateDirectory = "fastnetmon"; # for license file
        };

        unitConfig = {
          # Disable logic which shuts service when we do too many restarts
          # We do restarts from sudo fcli commit and it's expected that we may have many restarts
          # Details: https://github.com/systemd/systemd/issues/2416
          StartLimitInterval = 0;
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.fastnetmon-setup = {
        after = [ "ferretdb.service" ];

        path = with pkgs; [
          fastnetmon-advanced
          config.systemd.package
        ];

        script = ''
          fcli create_configuration
          fcli delete hostgroup global
          fcli import_configuration ${config_tar}
          systemctl --no-block try-restart fastnetmon
        '';

        serviceConfig.Type = "oneshot";
        wantedBy = [ "multi-user.target" ];
      };

      # We don't use the existing gobgp NixOS module and package, because the gobgp
      # version might not be compatible with fastnetmon. Also, the service name
      # _must_ be 'gobgp' and not 'gobgpd', so that fastnetmon can reload the config.
      systemd.services.gobgp = {
        after = [ "network.target" ];
        description = "GoBGP Routing Daemon";

        serviceConfig = {
          AmbientCapabilities = "cap_net_bind_service";
          DynamicUser = true;
          ExecReload = "${pkgs.fastnetmon-advanced}/bin/fnm-gobgpd -r";
          ExecStart = "${pkgs.fastnetmon-advanced}/bin/fnm-gobgpd -f /run/fastnetmon/gobgpd.conf --sdnotify";
          ExecStartPre = "${pkgs.fastnetmon-advanced}/bin/fnm-gobgpd -f /run/fastnetmon/gobgpd.conf -d";
          SupplementaryGroups = [ "fastnetmon" ];
          Type = "notify";
        };

        unitConfig = {
          ConditionPathExists = "/run/fastnetmon/gobgpd.conf";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.enableAdvancedTrafficPersistence) {
      environment.etc."fastnetmon/traffic_db.conf".text = builtins.toJSON cfg.traffic_db.settings;
      ## Advanced Traffic persistence
      ## https://fastnetmon.com/docs-fnm-advanced/fastnetmon-advanced-traffic-persistency/
      services.clickhouse.enable = true;
      services.fastnetmon-advanced.settings.traffic_db = true;

      services.fastnetmon-advanced.traffic_db.settings = {
        clickhouse_batch_delay = lib.mkDefault 1;
        clickhouse_batch_size = lib.mkDefault 1000;
        clickhouse_host = lib.mkDefault "127.0.0.1";
        clickhouse_password = lib.mkDefault "";
        clickhouse_port = lib.mkDefault 9000;
        clickhouse_user = lib.mkDefault "default";
        traffic_db_host = lib.mkDefault "127.0.0.1";
        traffic_db_port = lib.mkDefault 8100;
      };

      systemd.services.traffic_db = {
        after = [ "network.target" ];

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${pkgs.fastnetmon-advanced}/bin/traffic_db";
          # Restart service when it fails due to any reasons, we need to keep processing traffic no matter what happened
          Restart = "on-failure";
          RestartSec = "5s";
        };

        wantedBy = [ "multi-user.target" ];
      };

    })
  ];

  meta.maintainers = with lib.maintainers; [ yureka-wdz ];
}

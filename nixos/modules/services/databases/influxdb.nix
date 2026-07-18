{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.influxdb;

  settingsFormat = pkgs.formats.toml { };
in
{

  imports = [
    # FIXME remove after 26.11
    (lib.mkRenamedOptionModule
      [ "services" "influxdb" "extraConfig" ]
      [ "services" "influxdb" "settings" ]
    )
  ];

  ###### interface
  options = {

    services.influxdb = {

      enable = lib.mkEnableOption "the influxdb server";
      package = lib.mkPackageOption pkgs "influxdb" { };

      dataDir = lib.mkOption {
        default = "/var/db/influxdb";
        description = "Data directory for influxd data files.";
        type = lib.types.path;
      };

      group = lib.mkOption {
        default = "influxdb";
        description = "Group under which influxdb runs";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };
        description = "Extra configuration options for influxdb";

        type = lib.types.submodule {
          config =
            let
              mkAllOptionDefault = lib.mapAttrs (n: lib.mkOptionDefault);
            in
            {
              admin = mkAllOptionDefault {
                bind-address = ":8083";
                enabled = true;
                https-enabled = false;
              };

              cluster = mkAllOptionDefault {
                shard-writer-timeout = "5s";
                write-timeout = "5s";
              };

              collectd = lib.mkOptionDefault [
                {
                  bind-address = ":25826";
                  database = "collectd_db";
                  enabled = false;
                  typesdb = "${pkgs.collectd-data}/share/collectd/types.db";
                }
              ];

              continuous_queries = mkAllOptionDefault {
                compute-no-more-than = "2m";
                compute-runs-per-interval = 10;
                enabled = true;
                log-enabled = true;
                recompute-no-older-than = "10m";
                recompute-previous-n = 2;
              };

              data = mkAllOptionDefault {
                dir = "${cfg.dataDir}/data";
                max-wal-size = 104857600;
                wal-dir = "${cfg.dataDir}/wal";
                wal-enable-logging = true;
                wal-flush-interval = "10m";
                wal-partition-flush-delay = "2s";
              };

              # We can't make lists sensibly overrideable, so you have to override
              # them whole
              graphite = lib.mkOptionDefault [
                {
                  enabled = false;
                }
              ];

              hinted-handoff = mkAllOptionDefault {
                dir = "${cfg.dataDir}/hh";
                enabled = true;
                max-age = "168h";
                max-size = 1073741824;
                retry-interval = "1s";
                retry-rate-limit = 0;
              };

              http = mkAllOptionDefault {
                auth-enabled = false;
                bind-address = ":8086";
                enabled = true;
                https-enabled = false;
                log-enabled = true;
                pprof-enabled = false;
                write-tracing = false;
              };

              monitor = mkAllOptionDefault {
                store-database = "_internal";
                store-enabled = false;
                store-interval = "10s";
              };

              opentsdb = lib.mkOptionDefault [
                {
                  enabled = false;
                }
              ];

              retention = mkAllOptionDefault {
                check-interval = "30m";
                enabled = true;
              };

              udp = lib.mkOptionDefault [
                {
                  enabled = false;
                }
              ];

              meta = mkAllOptionDefault {
                bind-address = ":8088";
                commit-timeout = "50ms";
                dir = "${cfg.dataDir}/meta";
                election-timeout = "1s";
                heartbeat-timeout = "1s";
                hostname = "localhost";
                leader-lease-timeout = "500ms";
                retention-autocreate = true;
              };
            };

          freeformType = settingsFormat.type;
        };
      };

      user = lib.mkOption {
        default = "influxdb";
        description = "User account under which influxdb runs";
        type = lib.types.str;
      };
    };
  };

  ###### implementation
  config = lib.mkIf config.services.influxdb.enable {

    systemd.services.influxdb = {
      after = [ "network.target" ];
      description = "InfluxDB Server";

      postStart =
        let
          scheme = if cfg.settings.http.https-enabled or false then "-k https" else "http";
          inherit (cfg.settings.http) bind-address;
          bindAddr = if lib.hasPrefix ":" bind-address then "127.0.0.1${bind-address}" else bind-address;
        in
        lib.mkBefore ''
          until ${pkgs.curl.bin}/bin/curl -s -o /dev/null ${scheme}://${bindAddr}/ping; do
            sleep 1;
          done
        '';

      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/influxd -config "${settingsFormat.generate "config.toml" cfg.settings}"'';
        Group = cfg.group;
        Restart = "on-failure";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0770 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.mkIf (cfg.group == "influxdb") {
      influxdb.gid = config.ids.gids.influxdb;
    };

    users.users = lib.mkIf (cfg.user == "influxdb") {
      influxdb = {
        description = "Influxdb daemon user";
        group = "influxdb";
        uid = config.ids.uids.influxdb;
      };
    };
  };
}

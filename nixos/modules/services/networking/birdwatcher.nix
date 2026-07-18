{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.birdwatcher;
in
{
  options = {
    services.birdwatcher = {
      enable = lib.mkEnableOption "Birdwatcher";
      package = lib.mkPackageOption pkgs "birdwatcher" { };

      flags = lib.mkOption {
        default = [ ];

        description = ''
          Flags to append to the program call
        '';

        example = [
          "-worker-pool-size 16"
          "-6"
        ];

        type = lib.types.listOf lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          birdwatcher configuration, for configuration options see the example on [github](https://github.com/alice-lg/birdwatcher/blob/master/etc/birdwatcher/birdwatcher.conf)
        '';

        example = lib.literalExpression ''
          [server]
          allow_from = []
          allow_uncached = false
          modules_enabled = ["status",
                             "protocols",
                             "protocols_bgp",
                             "protocols_short",
                             "routes_protocol",
                             "routes_peer",
                             "routes_table",
                             "routes_table_filtered",
                             "routes_table_peer",
                             "routes_filtered",
                             "routes_prefixed",
                             "routes_noexport",
                             "routes_pipe_filtered_count",
                             "routes_pipe_filtered"
                            ]

          [status]
          reconfig_timestamp_source = "bird"
          reconfig_timestamp_match = "# created: (.*)"

          filter_fields = []

          [bird]
          listen = "0.0.0.0:29184"
          config = "/etc/bird/bird.conf"
          birdc  = "''${pkgs.bird2}/bin/birdc"
          ttl = 5 # time to live (in minutes) for caching of cli output

          [parser]
          filter_fields = []

          [cache]
          use_redis = false # if not using redis cache, activate housekeeping to save memory!

          [housekeeping]
          interval = 5
          force_release_memory = true
        '';

        type = lib.types.lines;
      };
    };
  };

  config =
    let
      flagsStr = lib.escapeShellArgs cfg.flags;
    in
    lib.mkIf cfg.enable {
      environment.etc."birdwatcher/birdwatcher.conf".source = pkgs.writeTextFile {
        name = "birdwatcher.conf";
        text = cfg.settings;
      };

      systemd.services = {
        birdwatcher = {
          after = [ "network.target" ];
          description = "Birdwatcher";

          serviceConfig = {
            BindReadOnlyPaths = [
              "-/etc/resolv.conf"
              "-/etc/nsswitch.conf"
              "-/etc/ssl/certs"
              "-/etc/static/ssl/certs"
              "-/etc/hosts"
              "-/etc/localtime"
            ];

            ExecStart = "${cfg.package}/bin/birdwatcher";
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateMounts = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "strict";
            Restart = "on-failure";
            RestartSec = 15;
            RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6" ];
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            StateDirectoryMode = "0700";
            SystemCallArchitectures = "native";
            SystemCallFilter = "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap";
            Type = "simple";
            UMask = "0117";
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network.target" ];
        };
      };
    };
}

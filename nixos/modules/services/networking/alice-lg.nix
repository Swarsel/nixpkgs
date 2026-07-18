{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.alice-lg;
  settingsFormat = pkgs.formats.ini { };
in
{
  options = {
    services.alice-lg = {
      enable = lib.mkEnableOption "Alice Looking Glass";
      package = lib.mkPackageOption pkgs "alice-lg" { };

      settings = lib.mkOption {
        default = { };

        description = ''
          alice-lg configuration, for configuration options see the example on [github](https://github.com/alice-lg/alice-lg/blob/main/etc/alice-lg/alice.example.conf)
        '';

        example = lib.literalExpression ''
          {
            server = {
              # configures the built-in webserver and provides global application settings
              listen_http = "127.0.0.1:7340";
              enable_prefix_lookup = true;
              asn = 9033;
              store_backend = postgres;
              routes_store_refresh_parallelism = 5;
              neighbors_store_refresh_parallelism = 10000;
              routes_store_refresh_interval = 5;
              neighbors_store_refresh_interval = 5;
            };
            postgres = {
              url = "postgres://postgres:postgres@localhost:5432/alice";
              min_connections = 2;
              max_connections = 128;
            };
            pagination = {
              routes_filtered_page_size = 250;
              routes_accepted_page_size = 250;
              routes_not_exported_page_size = 250;
            };
          }
        '';

        type = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc."alice-lg/alice.conf".source = settingsFormat.generate "alice-lg.conf" cfg.settings;
    };

    systemd.services = {
      alice-lg = {
        after = [ "network.target" ];
        description = "Alice Looking Glass";

        serviceConfig = {
          BindReadOnlyPaths = [
            "-/etc/resolv.conf"
            "-/etc/nsswitch.conf"
            "-/etc/ssl/certs"
            "-/etc/static/ssl/certs"
            "-/etc/hosts"
            "-/etc/localtime"
          ];

          CapabilityBoundingSet = "";
          DynamicUser = true;
          ExecStart = "${cfg.package}/bin/alice-lg";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          Restart = "on-failure";
          RestartSec = 15;
          RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectoryMode = "0700";
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap";
          Type = "simple";
          UMask = "0007";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network.target" ];
      };
    };
  };
}

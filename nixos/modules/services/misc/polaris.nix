{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.polaris;
  settingsFormat = pkgs.formats.toml { };
in
{
  options = {
    services.polaris = {
      enable = lib.mkEnableOption "Polaris Music Server";
      package = lib.mkPackageOption pkgs "polaris" { };

      extraGroups = lib.mkOption {
        default = [ ];
        description = "Polaris' auxiliary groups.";
        example = lib.literalExpression ''["media" "music"]'';
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "polaris";
        description = "Group under which Polaris is run.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open the configured port in the firewall.
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 5050;

        description = ''
          The port which the Polaris REST api and web UI should listen to.
          Note: polaris is hardcoded to listen to the hostname "0.0.0.0".
        '';

        type = lib.types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Contents for the TOML Polaris config, applied each start.
          Although poorly documented, an example may be found here:
          [test-config.toml](https://github.com/agersant/polaris/blob/374d0ca56fc0a466d797a4b252e2078607476797/test-data/config.toml)
        '';

        example = lib.literalExpression ''
          {
            settings.reindex_every_n_seconds = 7*24*60*60; # weekly, default is 1800
            settings.album_art_pattern =
              "(cover|front|folder)\.(jpeg|jpg|png|bmp|gif)";
            mount_dirs = [
              {
                name = "NAS";
                source = "/mnt/nas/music";
              }
              {
                name = "Local";
                source = "/home/my_user/Music";
              }
            ];
          }
        '';

        type = settingsFormat.type;
      };

      user = lib.mkOption {
        default = "polaris";
        description = "User account under which Polaris runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.polaris = {
      after = [ "network.target" ];
      description = "Polaris Music Server";

      serviceConfig = rec {
        # Security options:
        #NoNewPrivileges = true; # implied by DynamicUser
        #RemoveIPC = true; # implied by DynamicUser
        AmbientCapabilities = "";
        CacheDirectory = "polaris";
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/polaris"
            "--foreground"
            "--port"
            cfg.port
            "--database"
            "/var/lib/${StateDirectory}/db.sqlite"
            "--cache"
            "/var/cache/${CacheDirectory}"
          ]
          ++ lib.optionals (cfg.settings != { }) [
            "--config"
            (settingsFormat.generate "polaris-config.toml" cfg.settings)
          ]
        );

        Group = cfg.group;
        LockPersonality = true;
        #PrivateTmp = true; # implied by DynamicUser
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "polaris";
        SupplementaryGroups = cfg.extraGroups;
        #RestrictSUIDSGID = true; # implied by DynamicUser
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@obsolete"
          "~@privileged"
          "~@setuid"
        ];

        Type = "notify";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ pbsds ];
}

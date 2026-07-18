{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    maintainers
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;
  inherit (lib.types)
    bool
    path
    port
    str
    submodule
    ;
  cfg = config.services.qui;

  stateDir = "/var/lib/qui";
  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "qui.toml" cfg.settings;
in
{
  options = {
    services.qui = {
      enable = mkEnableOption "qui";
      package = mkPackageOption pkgs "qui" { };

      group = mkOption {
        default = "qui";
        description = "Group to run qui as.";
        example = "torrents";
        type = str;
      };

      openFirewall = mkOption {
        default = false;
        description = "Whether or not to open ports in the firewall for qui.";
        type = bool;
      };

      secretFile = mkOption {
        description = ''
          Path to a file that contains the session secret. The session secret
          can be generated with `openssl rand -hex 32`.
        '';

        example = "/run/secrets/qui-session.txt";
        type = path;
      };

      settings = mkOption {
        default = { };

        description = ''
          qui configuration options.

          Refer to the [template config](https://github.com/autobrr/qui/blob/main/internal/config/config.go)
          in the source code for the available options.
          The documentation contains the available [environment variables](https://getqui.com/docs/configuration/environment/),
          this can be used to get an overview.
        '';

        example = {
          logLevel = "DEBUG";
          metricsEnabled = true;
          port = 7777;
        };

        type = submodule {
          options = {
            host = mkOption {
              default = "127.0.0.1";
              description = "The host address qui listens on.";
              type = str;
            };

            port = mkOption {
              default = 7476;
              description = "The port qui listens on.";
              type = port;
            };
          };

          freeformType = configFormat.type;
        };
      };

      user = mkOption {
        default = "qui";
        description = "User to run qui as.";
        type = str;
      };

    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? sessionSecret);

        message = ''
          Session secrets should not be passed via settings, as
          these are stored in the world-readable nix store.

          Use the secretFile option instead.'';
      }
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.port ];
    };

    systemd.services.qui = {
      after = [ "network-online.target" ];
      description = "qui: alternative qBittorrent webUI";

      serviceConfig = {
        # Based on qbittorrent and nemorosa hardening settings
        # Similar to what systemd hardening helper suggests
        CapabilityBoundingSet = "";
        Environment = [ "QUI__SESSION_SECRET_FILE=%d/sessionSecret" ];
        ExecStart = "${getExe cfg.package} serve --config-dir %S/qui";

        ExecStartPre = ''
          ${pkgs.coreutils}/bin/install -m 600 '${configFile}' '%S/qui/config.toml'
        '';

        Group = cfg.group;
        LoadCredential = "sessionSecret:${cfg.secretFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "yes";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        # This should allow for hardlinking to torrent client files
        ProtectSystem = "full";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "qui";
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users = {
      groups = mkIf (cfg.group == "qui") {
        qui = { };
      };

      users = mkIf (cfg.user == "qui") {
        qui = {
          description = "qui user";
          group = cfg.group;
          home = stateDir;
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = with maintainers; [ undefined-landmark ];
}

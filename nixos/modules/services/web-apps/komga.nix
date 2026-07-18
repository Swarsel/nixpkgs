{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.komga;
  inherit (lib) mkOption mkEnableOption maintainers;
  inherit (lib.types)
    port
    str
    bool
    submodule
    ;

  settingsFormat = pkgs.formats.yaml { };
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "services"
        "komga"
        "port"
      ]
      [
        "services"
        "komga"
        "settings"
        "server"
        "port"
      ]
    )
  ];

  options = {
    services.komga = {
      enable = mkEnableOption "Komga, a free and open source comics/mangas media server";

      group = mkOption {
        default = "komga";
        description = "Group under which Komga runs.";
        type = str;
      };

      openFirewall = mkOption {
        default = false;
        description = "Whether to open the firewall for the port in {option}`services.komga.settings.server.port`.";
        type = bool;
      };

      settings = lib.mkOption {
        description = ''
          Komga configuration.

          See [documentation](https://komga.org/docs/installation/configuration).
        '';

        type = submodule {
          options.server.port = mkOption {
            default = 8080;
            description = "The port that Komga will listen on.";
            type = port;
          };

          freeformType = settingsFormat.type;
        };
      };

      stateDir = mkOption {
        default = "/var/lib/komga";
        description = "State and configuration directory Komga will use.";
        type = str;
      };

      user = mkOption {
        default = "komga";
        description = "User account under which Komga runs.";
        type = str;
      };
    };
  };

  config =
    let
      inherit (lib) mkIf getExe;
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.settings.komga.config-dir or cfg.stateDir) == cfg.stateDir;
          message = "You must use the `services.komga.stateDir` option to properly configure `komga.config-dir`.";
        }
      ];

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.server.port ];

      systemd.services.komga = {
        after = [ "network-online.target" ];
        description = "Komga is a free and open source comics/mangas media server";

        environment = {
          KOMGA_CONFIGDIR = cfg.stateDir;
        };

        serviceConfig = {
          CapabilityBoundingSet = "";
          ExecStart = getExe pkgs.komga;
          Group = cfg.group;
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "all";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "full";
          RemoveIPC = true;
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = mkIf (cfg.stateDir == "/var/lib/komga") "komga";
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" ];
          Type = "simple";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

      systemd.tmpfiles.settings."10-komga" = {
        ${cfg.stateDir}.d = {
          inherit (cfg) user group;
        };

        "${cfg.stateDir}/application.yml"."L+" = {
          argument = toString (settingsFormat.generate "application.yml" cfg.settings);
        };
      };

      users.groups = mkIf (cfg.group == "komga") { komga = { }; };

      users.users = mkIf (cfg.user == "komga") {
        komga = {
          description = "Komga Daemon user";
          group = cfg.group;
          home = cfg.stateDir;
          isSystemUser = true;
        };
      };
    };

  meta.maintainers = with maintainers; [
    govanify
    tebriel
  ];
}

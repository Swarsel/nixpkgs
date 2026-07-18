{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tautulli;
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "plexpy" ] [ "services" "tautulli" ])
  ];

  options = {
    services.tautulli = {
      enable = lib.mkEnableOption "Tautulli Plex Monitor";
      package = lib.mkPackageOption pkgs "tautulli" { };

      configFile = lib.mkOption {
        default = "/var/lib/plexpy/config.ini";
        description = "The location of Tautulli's config file.";
        type = lib.types.str;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/plexpy";
        description = "The directory where Tautulli stores its data files.";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "nogroup";
        description = "Group under which Tautulli runs.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for Tautulli.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 8181;
        description = "TCP port where Tautulli listens.";
        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "plexpy";
        description = "User account under which Tautulli runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.tautulli = {
      after = [ "network.target" ];
      description = "Tautulli Plex Monitor";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/tautulli --datadir ${cfg.dataDir} --config ${cfg.configFile} --port ${toString cfg.port} --pidfile ${cfg.dataDir}/tautulli.pid --nolaunch";
        Group = cfg.group;
        GuessMainPID = "false";
        Restart = "on-failure";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${cfg.user} ${cfg.group} - -"
    ];

    users.users = lib.mkIf (cfg.user == "plexpy") {
      plexpy = {
        group = cfg.group;
        uid = config.ids.uids.plexpy;
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ombi;

in
{
  options = {
    services.ombi = {
      enable = lib.mkEnableOption ''
        Ombi, a web application that automatically gives your shared Plex or
        Emby users the ability to request content by themselves!

        Optionally see <https://docs.ombi.app/info/reverse-proxy>
        on how to set up a reverse proxy
      '';

      package = lib.mkPackageOption pkgs "ombi" { };

      dataDir = lib.mkOption {
        default = "/var/lib/ombi";
        description = "The directory where Ombi stores its data files.";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "ombi";
        description = "Group under which Ombi runs.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Ombi web interface.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 5000;
        description = "The port for the Ombi web interface.";
        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "ombi";
        description = "User account under which Ombi runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.ombi = {
      after = [ "network.target" ];
      description = "Ombi";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --storage '${cfg.dataDir}' --host 'http://*:${toString cfg.port}'";
        Group = cfg.group;
        Restart = "on-failure";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.mkIf (cfg.group == "ombi") { ombi = { }; };

    users.users = lib.mkIf (cfg.user == "ombi") {
      ombi = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };
}

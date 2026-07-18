{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.audiobookshelf;
in
{
  options = {
    services.audiobookshelf = {
      enable = mkEnableOption "Audiobookshelf, self-hosted audiobook and podcast server";
      package = mkPackageOption pkgs "audiobookshelf" { };

      dataDir = mkOption {
        default = "audiobookshelf";
        description = "Path to Audiobookshelf config and metadata inside of /var/lib.";
        type = types.str;
      };

      group = mkOption {
        default = "audiobookshelf";
        description = "Group under which Audiobookshelf runs.";
        type = types.str;
      };

      host = mkOption {
        default = "127.0.0.1";
        description = "The host Audiobookshelf binds to.";
        example = "0.0.0.0";
        type = types.str;
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for the Audiobookshelf web interface.";
        type = types.bool;
      };

      port = mkOption {
        default = 8000;
        description = "The TCP port Audiobookshelf will listen on.";
        type = types.port;
      };

      user = mkOption {
        default = "audiobookshelf";
        description = "User account under which Audiobookshelf runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.audiobookshelf = {
      after = [ "network.target" ];
      description = "Audiobookshelf is a self-hosted audiobook and podcast server";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/audiobookshelf --host ${cfg.host} --port ${toString cfg.port}";
        Group = cfg.group;
        Restart = "on-failure";
        StateDirectory = cfg.dataDir;
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = "/var/lib/${cfg.dataDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "audiobookshelf") {
      audiobookshelf = { };
    };

    users.users = mkIf (cfg.user == "audiobookshelf") {
      audiobookshelf = {
        group = cfg.group;
        home = "/var/lib/${cfg.dataDir}";
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with maintainers; [ wietsedv ];
}

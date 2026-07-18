{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lidarr;
  servarr = import ./settings-options.nix { inherit lib pkgs; };
in
{
  options = {
    services.lidarr = {
      enable = lib.mkEnableOption "Lidarr, a Usenet/BitTorrent music downloader";
      package = lib.mkPackageOption pkgs "lidarr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/lidarr/.config/Lidarr";
        description = "The directory where Lidarr stores its data files.";
        type = lib.types.str;
      };

      environmentFiles = servarr.mkServarrEnvironmentFiles "lidarr";

      group = lib.mkOption {
        default = "lidarr";

        description = ''
          Group under which Lidarr runs.
        '';

        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for Lidarr
        '';

        type = lib.types.bool;
      };

      settings = servarr.mkServarrSettingsOptions "lidarr" 8686;

      user = lib.mkOption {
        default = "lidarr";

        description = ''
          User account under which Lidarr runs.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    systemd.services.lidarr = {
      after = [ "network.target" ];
      description = "Lidarr";
      environment = servarr.mkServarrSettingsEnvVars "LIDARR" cfg.settings;

      serviceConfig = {
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${cfg.package}/bin/Lidarr -nobrowser -data='${cfg.dataDir}'";
        Group = cfg.group;
        Restart = "on-failure";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-lidarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    users.groups = lib.mkIf (cfg.group == "lidarr") {
      lidarr = {
        gid = config.ids.gids.lidarr;
      };
    };

    users.users = lib.mkIf (cfg.user == "lidarr") {
      lidarr = {
        group = cfg.group;
        home = "/var/lib/lidarr";
        uid = config.ids.uids.lidarr;
      };
    };
  };
}

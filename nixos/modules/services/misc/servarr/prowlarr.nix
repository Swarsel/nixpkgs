{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prowlarr;
  servarr = import ./settings-options.nix { inherit lib pkgs; };
  isCustomDataDir = cfg.dataDir != "/var/lib/prowlarr";
in
{
  options = {
    services.prowlarr = {
      enable = lib.mkEnableOption "Prowlarr, an indexer manager/proxy for Torrent trackers and Usenet indexers";
      package = lib.mkPackageOption pkgs "prowlarr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/prowlarr";

        description = ''
          The directory where Prowlarr stores its data files.

          Note: A bind mount will be used to mount the directory at the expected location
          if a different value than `/var/lib/prowlarr` is used.
        '';

        type = lib.types.str;
      };

      environmentFiles = servarr.mkServarrEnvironmentFiles "prowlarr";

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Prowlarr web interface.";
        type = lib.types.bool;
      };

      settings = servarr.mkServarrSettingsOptions "prowlarr" 9696;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    systemd = {
      mounts = lib.optional isCustomDataDir {
        options = "bind";
        wantedBy = [ "local-fs.target" ];
        what = cfg.dataDir;
        where = "/var/lib/private/prowlarr";
      };

      services.prowlarr = {
        after = [ "network.target" ];
        description = "Prowlarr";

        environment = servarr.mkServarrSettingsEnvVars "PROWLARR" cfg.settings // {
          HOME = "/var/empty";
        };

        serviceConfig = {
          DynamicUser = true;
          EnvironmentFile = cfg.environmentFiles;
          ExecStart = "${lib.getExe cfg.package} -nobrowser -data=/var/lib/prowlarr";
          Restart = "on-failure";
          StateDirectory = "prowlarr";
          Type = "simple";
        };

        unitConfig.RequiresMountsFor = [ cfg.dataDir ];
        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.settings."10-prowlarr".${cfg.dataDir}.d = lib.mkIf isCustomDataDir {
        group = "root";
        mode = "0700";
        user = "root";
      };
    };
  };
}

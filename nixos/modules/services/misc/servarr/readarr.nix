{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.readarr;
  servarr = import ./settings-options.nix { inherit lib pkgs; };
in
{
  options = {
    services.readarr = {
      enable = lib.mkEnableOption "Readarr, a Usenet/BitTorrent ebook downloader";
      package = lib.mkPackageOption pkgs "readarr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/readarr/";
        description = "The directory where Readarr stores its data files.";
        type = lib.types.str;
      };

      environmentFiles = servarr.mkServarrEnvironmentFiles "readarr";

      group = lib.mkOption {
        default = "readarr";

        description = ''
          Group under which Readarr runs.
        '';

        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for Readarr
        '';

        type = lib.types.bool;
      };

      settings = servarr.mkServarrSettingsOptions "readarr" 8787;

      user = lib.mkOption {
        default = "readarr";

        description = ''
          User account under which Readarr runs.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    systemd.services.readarr = {
      after = [ "network.target" ];
      description = "Readarr";
      environment = servarr.mkServarrSettingsEnvVars "READARR" cfg.settings;

      serviceConfig = {
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${cfg.package}/bin/Readarr -nobrowser -data='${cfg.dataDir}'";
        Group = cfg.group;
        Restart = "on-failure";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-readarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    users.groups = lib.mkIf (cfg.group == "readarr") {
      readarr = { };
    };

    users.users = lib.mkIf (cfg.user == "readarr") {
      readarr = {
        description = "Readarr service";
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };
}

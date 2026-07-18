{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.whisparr;
  servarr = import ./settings-options.nix { inherit lib pkgs; };
in
{
  options = {
    services.whisparr = {
      enable = lib.mkEnableOption "Whisparr";
      package = lib.mkPackageOption pkgs "whisparr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/whisparr/.config/Whisparr";
        description = "The directory where Whisparr stores its data files.";
        type = lib.types.path;
      };

      environmentFiles = servarr.mkServarrEnvironmentFiles "whisparr";

      group = lib.mkOption {
        default = "whisparr";
        description = "Group under which Whisparr runs.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Whisparr web interface.";
        type = lib.types.bool;
      };

      settings = servarr.mkServarrSettingsOptions "whisparr" 6969;

      user = lib.mkOption {
        default = "whisparr";
        description = "User account under which Whisparr runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    systemd.services.whisparr = {
      after = [ "network.target" ];
      description = "Whisparr";
      environment = servarr.mkServarrSettingsEnvVars "WHISPARR" cfg.settings;

      serviceConfig = {
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${lib.getExe cfg.package} -nobrowser -data='${cfg.dataDir}'";
        Group = cfg.group;
        Restart = "on-failure";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -" ];
    users.groups.whisparr = lib.mkIf (cfg.group == "whisparr") { };

    users.users = lib.mkIf (cfg.user == "whisparr") {
      whisparr = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };
}

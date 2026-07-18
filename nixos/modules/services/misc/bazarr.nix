{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bazarr;
in
{
  options = {
    services.bazarr = {
      enable = lib.mkEnableOption "bazarr, a subtitle manager for Sonarr and Radarr";
      package = lib.mkPackageOption pkgs "bazarr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/bazarr";
        description = "The directory where Bazarr stores its data files.";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "bazarr";
        description = "Group under which bazarr runs.";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = 6767;
        description = "Port on which the bazarr web interface should listen";
        type = lib.types.port;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the bazarr web interface.";
        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "bazarr";
        description = "User account under which bazarr runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    systemd.services.bazarr = {
      after = [ "network.target" ];
      description = "Bazarr";

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "start-bazarr" ''
          ${cfg.package}/bin/bazarr \
            --config '${cfg.dataDir}' \
            --port ${toString cfg.listenPort} \
            --no-update True
        '';

        Group = cfg.group;
        KillSignal = "SIGINT";
        Restart = "on-failure";
        SuccessExitStatus = "0 156";
        SyslogIdentifier = "bazarr";
        Type = "simple";
        User = cfg.user;
      };

      unitConfig.RequiresMountsFor = [ cfg.dataDir ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-bazarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    users.groups = lib.mkIf (cfg.group == "bazarr") {
      bazarr = { };
    };

    users.users = lib.mkIf (cfg.user == "bazarr") {
      bazarr = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };
}

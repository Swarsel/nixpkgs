{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.todesk;
in
{
  options = {
    services.todesk.enable = lib.mkEnableOption "ToDesk daemon";
    services.todesk.package = lib.mkPackageOption pkgs "todesk" { };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.todeskd = {
      description = "ToDesk Daemon Service";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGINT $MAINPID";
        ExecStart = "${cfg.package}/bin/todesk service";
        PrivateTmp = true;
        ProtectHome = "read-only";
        ProtectSystem = "strict";
        RemoveIPC = "yes";
        Restart = "on-failure";
        StateDirectory = "todesk";
        StateDirectoryMode = "0777"; # Desktop application read and write /opt/todesk/config/config.ini. Such a pain!
        Type = "simple";
        WorkingDirectory = "/var/lib/todesk";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "display-manager.service"
        "nss-lookup.target"
      ];
    };
  };
}

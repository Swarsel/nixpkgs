{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.netclient;
in
{
  options.services.netclient = {
    enable = lib.mkEnableOption "Netclient Daemon";
    package = lib.mkPackageOption pkgs "netclient" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.netclient = {
      after = [ "network-online.target" ];
      description = "Netclient Daemon";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} daemon";
        Restart = "on-failure";
        RestartSec = "15s";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ wexder ];
}

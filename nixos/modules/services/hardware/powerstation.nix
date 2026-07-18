{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.powerstation;
in
{
  options.services.powerstation = {
    enable = lib.mkEnableOption "PowerStation";
    package = lib.mkPackageOption pkgs "powerstation" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.powerstation = {
      after = [ "graphical-session.target" ];
      description = "PowerStation Service";

      environment = {
        XDG_DATA_DIRS = "/run/current-system/sw/share";
      };

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Group = "root";
        User = "root";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ shadowapex ];
}

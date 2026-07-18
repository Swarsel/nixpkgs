{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.inputplumber;
in
{
  options.services.inputplumber = {
    enable = lib.mkEnableOption "InputPlumber";
    package = lib.mkPackageOption pkgs "inputplumber" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.inputplumber = {
      description = "InputPlumber Service";

      environment = {
        XDG_DATA_DIRS = "/run/current-system/sw/share";
      };

      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
        RestartSec = "5";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ shadowapex ];
}

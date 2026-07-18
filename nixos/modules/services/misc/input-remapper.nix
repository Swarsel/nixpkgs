{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.input-remapper;
in
{
  options = {
    services.input-remapper = {
      enable = lib.mkEnableOption "input-remapper, an easy to use tool to change the mapping of your input device buttons";
      package = lib.mkPackageOption pkgs "input-remapper" { };
      enableUdevRules = lib.mkEnableOption "udev rules added by input-remapper to handle hotplugged devices. Currently disabled by default due to <https://github.com/sezanzeb/input-remapper/issues/140>";

      serviceWantedBy = lib.mkOption {
        default = [ "graphical.target" ];
        description = "Specifies the WantedBy setting for the input-remapper service.";
        example = [ "multi-user.target" ];
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];
    services.udev.packages = lib.mkIf cfg.enableUdevRules [ cfg.package ];
    systemd.packages = [ cfg.package ];
    systemd.services.input-remapper.wantedBy = cfg.serviceWantedBy;
  };

  meta.maintainers = with lib.maintainers; [ LunNova ];
}

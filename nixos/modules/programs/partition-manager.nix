{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.partition-manager;
in
{
  options = {
    programs.partition-manager = {
      enable = lib.mkEnableOption "KDE Partition Manager";
      package = lib.mkPackageOption pkgs [ "kdePackages" "partitionmanager" ] { };
    };
  };

  config = lib.mkIf config.programs.partition-manager.enable {
    # `kpmcore` need to be installed to pull in polkit actions.
    environment.systemPackages = [
      cfg.package.kpmcore
      cfg.package
    ];

    services.dbus.packages = [ cfg.package.kpmcore ];
  };

  meta.maintainers = [ lib.maintainers.oxalica ];
}

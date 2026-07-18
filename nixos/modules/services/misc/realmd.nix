{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.services.realmd;
in
{
  options.services.realmd = {
    enable = mkEnableOption "realmd service for managing system enrollment in Active Directory domains";
    package = mkPackageOption pkgs "realmd" { };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.dbus = {
      enable = true;
      packages = [ cfg.package ];
    };

    systemd.services.realmd = {
      after = [
        "network.target"
        "dbus.service"
      ];

      description = "Realm and Domain Configuration";
      partOf = [ "dbus.service" ];
      requires = [ "dbus.service" ];

      serviceConfig = {
        BusName = "org.freedesktop.realmd";
        ExecStart = "${cfg.package}/libexec/realmd";
        RuntimeDirectory = "realmd";
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

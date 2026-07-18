{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.adw-bluetooth;
in
{
  options.services.adw-bluetooth = {
    enable = lib.mkEnableOption "Adwaita Bluetooth daemon";
    package = lib.mkPackageOption pkgs "adw-bluetooth" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];

    systemd.user.services.adw-bluetooth-daemon = {
      after = [ "bluetooth.target" ];
      description = "AdwBluetooth Daemon";

      serviceConfig = {
        BusName = "com.ezratweaver.AdwBluetoothDaemon";
        ExecStart = "${cfg.package}/libexec/adw-bluetooth-daemon";
        Type = "dbus";
      };

      wantedBy = [ "default.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ ezratweaver ];
}

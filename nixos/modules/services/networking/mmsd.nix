{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mmsd;
  dbusServiceFile = pkgs.writeTextDir "share/dbus-1/services/org.ofono.mms.service" ''
    [D-BUS Service]
    Name=org.ofono.mms
    SystemdService=dbus-org.ofono.mms.service

    # Exec= is still required despite SystemdService= being used:
    # https://github.com/freedesktop/dbus/blob/ef55a3db0d8f17848f8a579092fb05900cc076f5/test/data/systemd-activation/com.example.SystemdActivatable1.service
    Exec=${pkgs.coreutils}/bin/false mmsd
  '';
in
{
  options.services.mmsd = {
    enable = mkEnableOption "Multimedia Messaging Service Daemon";

    extraArgs = mkOption {
      default = [ ];
      description = "Extra arguments passed to `mmsd-tng`";
      example = [ "--debug" ];
      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    services.dbus.packages = [ dbusServiceFile ];

    systemd.user.services.mmsd = {
      after = [ "ModemManager.service" ];
      aliases = [ "dbus-org.ofono.mms.service" ];

      serviceConfig = {
        BusName = "org.ofono.mms";
        ExecStart = "${pkgs.mmsd-tng}/bin/mmsdtng " + escapeShellArgs cfg.extraArgs;
        Restart = "on-failure";
        Type = "dbus";
      };
    };
  };
}

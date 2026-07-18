{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.intune;
in
{
  options.services.intune = {
    enable = lib.mkEnableOption "Microsoft Intune";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.microsoft-identity-broker
      pkgs.intune-portal
    ];

    services.dbus.packages = [ pkgs.microsoft-identity-broker ];

    systemd.packages = [
      pkgs.microsoft-identity-broker
      pkgs.intune-portal
    ];

    systemd.tmpfiles.packages = [ pkgs.intune-portal ];
    users.groups.microsoft-identity-broker = { };

    users.users.microsoft-identity-broker = {
      group = "microsoft-identity-broker";
      isSystemUser = true;
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ rhysmdnz ];
  };
}

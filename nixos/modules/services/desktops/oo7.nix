{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.oo7;
in
{
  options.services.oo7 = {
    enable = lib.mkEnableOption ''
      oo7, a service providing the Secret Service D-Bus API
    '';
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.oo7 ];

    security = {
      pam.services.login.oo7.enable = true;

      wrappers.oo7-daemon = {
        capabilities = "cap_ipc_lock=ep";
        group = "root";
        owner = "root";
        source = "${pkgs.oo7-server}/libexec/oo7-daemon";
      };
    };

    services.dbus.packages = [ pkgs.oo7-server ];

    systemd = {
      packages = [ pkgs.oo7-server ];
      user.services.oo7-daemon.wantedBy = [ "default.target" ];
    };

    xdg.portal.extraPortals = [ pkgs.oo7-portal ];
  };

  meta = { inherit (pkgs.oo7.meta) maintainers; };
}

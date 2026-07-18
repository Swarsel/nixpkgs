{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.supergfxd;
  json = pkgs.formats.json { };
in
{
  options = {
    services.supergfxd = {
      enable = lib.mkEnableOption "the supergfxd service";

      settings = lib.mkOption {
        default = null;

        description = ''
          The content of /etc/supergfxd.conf.
          See <https://gitlab.com/asus-linux/supergfxctl/#config-options-etcsupergfxdconf>.
        '';

        type = lib.types.nullOr json.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."supergfxd.conf" = lib.mkIf (cfg.settings != null) {
      mode = "0644";
      source = json.generate "supergfxd.conf" cfg.settings;
    };

    environment.systemPackages = [ pkgs.supergfxctl ];
    services.dbus.enable = true;
    services.dbus.packages = [ pkgs.supergfxctl ];
    services.udev.packages = [ pkgs.supergfxctl ];
    systemd.packages = [ pkgs.supergfxctl ];

    systemd.services.supergfxd.path = [
      pkgs.kmod
      pkgs.pciutils
    ];

    systemd.services.supergfxd.wantedBy = [ "multi-user.target" ];
  };

  meta.maintainers = pkgs.supergfxctl.meta.maintainers;
}

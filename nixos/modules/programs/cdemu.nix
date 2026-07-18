{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cdemu;
in
{

  options = {
    programs.cdemu = {
      enable = lib.mkOption {
        default = false;

        description = ''
          {command}`cdemu` for members of
          {option}`programs.cdemu.group`.
        '';

        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "cdrom";

        description = ''
          Group that users must be in to use {command}`cdemu`.
        '';

        type = lib.types.str;
      };

      gui = lib.mkOption {
        default = true;

        description = ''
          Whether to install the {command}`cdemu` GUI (gCDEmu).
        '';

        type = lib.types.bool;
      };

      image-analyzer = lib.mkOption {
        default = true;

        description = ''
          Whether to install the image analyzer.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    boot = {
      extraModulePackages = [ config.boot.kernelPackages.vhba ];
      kernelModules = [ "vhba" ];
    };

    environment.systemPackages = [
      pkgs.cdemu-daemon
      pkgs.cdemu-client
    ]
    ++ lib.optional cfg.gui pkgs.gcdemu
    ++ lib.optional cfg.image-analyzer pkgs.image-analyzer;

    services = {
      dbus.packages = [ pkgs.cdemu-daemon ];

      udev.extraRules = ''
        KERNEL=="vhba_ctl", MODE="0660", OWNER="root", GROUP="${cfg.group}"
      '';
    };

    # Systemd User service
    # manually adapted from example in source package:
    # https://sourceforge.net/p/cdemu/code/ci/master/tree/cdemu-daemon/service-example/cdemu-daemon.service
    systemd.user.services.cdemu-daemon.description = "CDEmu daemon";

    systemd.user.services.cdemu-daemon.serviceConfig = {
      BusName = "net.sf.cdemu.CDEmuDaemon";
      ExecStart = "${lib.getExe pkgs.cdemu-daemon} --config-file \"%h/.config/cdemu-daemon\"";
      Restart = "no";
      Type = "dbus";
    };

    users.groups.${config.programs.cdemu.group} = { };
  };

}

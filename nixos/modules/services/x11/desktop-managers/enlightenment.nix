{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  e = pkgs.enlightenment;
  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager.enlightenment;

  GST_PLUGIN_PATH = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-libav
  ];

in

{
  imports = [
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "e19" "enable" ]
      [ "services" "xserver" "desktopManager" "enlightenment" "enable" ]
    )
  ];

  options = {

    environment.enlightenment.excludePackages = mkOption {
      default = [ ];
      description = "Which packages Enlightenment should exclude from the default environment";
      example = literalExpression "[ pkgs.enlightenment.ephoto ]";
      type = types.listOf types.package;
    };

    services.xserver.desktopManager.enlightenment.enable = mkOption {
      default = false;
      description = "Enable the Enlightenment desktop environment.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {

    environment.etc."X11/xkb".source = xcfg.xkb.dir;

    environment.pathsToLink = [
      "/etc/enlightenment"
      "/share/enlightenment"
      "/share/elementary"
      "/share/locale"
    ];

    environment.systemPackages = utils.removePackagesByName (with pkgs; [
      enlightenment.econnman
      enlightenment.efl
      enlightenment.enlightenment
      enlightenment.ecrire
      enlightenment.ephoto
      enlightenment.rage
      enlightenment.terminology
      xcursor-themes
    ]) config.environment.enlightenment.excludePackages;

    fonts.packages = [ pkgs.dejavu_fonts ];

    # Wrappers for programs installed by enlightenment that should be setuid
    security.wrappers = {
      enlightenment_ckpasswd = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${pkgs.enlightenment.enlightenment}/lib/enlightenment/utils/enlightenment_ckpasswd";
      };

      enlightenment_sys = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${pkgs.enlightenment.enlightenment}/lib/enlightenment/utils/enlightenment_sys";
      };

      enlightenment_system = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${pkgs.enlightenment.enlightenment}/lib/enlightenment/utils/enlightenment_system";
      };
    };

    services.dbus.packages = [ e.efl ];
    services.displayManager.sessionPackages = [ pkgs.enlightenment.enlightenment ];
    services.libinput.enable = mkDefault true;
    services.udisks2.enable = true;
    services.upower.enable = config.powerManagement.enable;

    services.xserver.displayManager.sessionCommands = ''
      if test "$XDG_CURRENT_DESKTOP" = "Enlightenment"; then
        export GST_PLUGIN_PATH="${GST_PLUGIN_PATH}"

        # make available for D-BUS user services
        #export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}:${config.system.path}/share:${e.efl}/share

        # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update
      fi
    '';

    systemd.user.services.efreet = {
      enable = true;
      description = "org.enlightenment.Efreet";

      serviceConfig = {
        ExecStart = "${e.efl}/bin/efreetd";
        StandardOutput = "null";
      };
    };

    systemd.user.services.ethumb = {
      enable = true;
      description = "org.enlightenment.Ethumb";

      serviceConfig = {
        ExecStart = "${e.efl}/bin/ethumbd";
        StandardOutput = "null";
      };
    };

  };

  meta = {
    teams = [ teams.enlightenment ];
  };

}

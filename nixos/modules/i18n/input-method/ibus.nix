{
  config,
  lib,
  pkgs,
  ...
}:
let
  imcfg = config.i18n.inputMethod;
  cfg = imcfg.ibus;
  ibusPackage = pkgs.ibus-with-plugins.override { plugins = cfg.engines; };
  ibusEngine = lib.types.mkOptionType {
    inherit (lib.types.package) descriptionClass merge;
    check = x: (lib.types.package.check x) && (lib.attrByPath [ "meta" "isIbusEngine" ] false x);
    name = "ibus-engine";
  };

  impanel = lib.optionalString (cfg.panel != null) "--panel=${cfg.panel}";

  ibusAutostart = pkgs.writeTextFile {
    destination = "/etc/xdg/autostart/ibus-daemon.desktop";
    name = "autostart-ibus-daemon";

    text = ''
      [Desktop Entry]
      Name=IBus
      Type=Application
      Exec=${ibusPackage}/bin/ibus-daemon --daemonize --xim ${impanel}
      # GNOME will launch ibus using systemd
      # ibus complains loudly when launched from this autoStart file under KDE
      # KDE will launch ibus from kwin if enabled in keyboard -> virtual keyboard
      NotShowIn=GNOME;KDE;
    '';
  };
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "programs" "ibus" "plugins" ]
      [ "i18n" "inputMethod" "ibus" "engines" ]
    )
  ];

  options = {
    i18n.inputMethod.ibus = {
      engines = lib.mkOption {
        default = [ ];

        description =
          let
            enginesDrv = lib.filterAttrs (lib.const lib.isDerivation) pkgs.ibus-engines;
            engines = lib.concatStringsSep ", " (map (name: "`${name}`") (lib.attrNames enginesDrv));
          in
          "Enabled IBus engines. Available engines are: ${engines}.";

        example = lib.literalExpression "with pkgs.ibus-engines; [ mozc hangul ]";
        type = with lib.types; listOf ibusEngine;
      };

      panel = lib.mkOption {
        default = null;
        description = "Replace the IBus panel with another panel.";
        example = lib.literalExpression ''"''${pkgs.kdePackages.plasma-desktop}/libexec/kimpanel-ibus-panel"'';
        type = with lib.types; nullOr path;
      };

      waylandFrontend = lib.mkOption {
        default = false;

        description = ''
          Use the Wayland input method frontend.
          This doesn't set `GTK_IM_MODULE` and `QT_IM_MODULE` environment variables.
          See [Using Fcitx 5 on Wayland](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#GTK_IM_MODULE).
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf (imcfg.enable && imcfg.type == "ibus") {
    environment.systemPackages = [
      ibusAutostart
    ];

    environment.variables = {
      XMODIFIERS = "@im=ibus";
    }
    // lib.optionalAttrs (!cfg.waylandFrontend) {
      GTK_IM_MODULE = "ibus";
      QT_IM_MODULE = "ibus";
    };

    i18n.inputMethod.package = ibusPackage;
    # Without dconf enabled it is impossible to use IBus
    programs.dconf.enable = true;
    programs.dconf.packages = [ ibusPackage ];

    services.dbus.packages = [
      ibusPackage
    ];

    xdg.portal.extraPortals = lib.mkIf config.xdg.portal.enable [
      ibusPackage
    ];
  };

  # uses attributes of the linked package
  meta.buildDocsInSandbox = false;
}

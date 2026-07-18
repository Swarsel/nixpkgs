{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.qtile;
in

{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "xserver"
      "windowManager"
      "qtile"
      "backend"
    ] "The qtile package now provides separate display sessions for both X11 and Wayland.")
  ];

  options.services.xserver.windowManager.qtile = {
    enable = mkEnableOption "qtile";
    package = mkPackageOption pkgs [ "python3" "pkgs" "qtile" ] { };

    configFile = mkOption {
      default = null;

      description = ''
        Path to the qtile configuration file.
        If null, $XDG_CONFIG_HOME/qtile/config.py will be used.
      '';

      example = literalExpression "./your_config.py";
      type = with types; nullOr path;
    };

    extraPackages = mkOption {
      default = _: [ ];

      defaultText = literalExpression ''
        python3Packages: with python3Packages; [];
      '';

      description = ''
        Extra Python packages available to Qtile.
        An example would be to include `python3Packages.qtile-extras`
        for additional unofficial widgets.
      '';

      example = literalExpression ''
        python3Packages: with python3Packages; [
          qtile-extras
        ];
      '';

      type = types.functionTo (types.listOf types.package);
    };

    finalPackage = mkOption {
      description = "The resulting Qtile package, bundled with extra packages";
      readOnly = true;
      type = types.package;
      visible = false;
    };
  };

  config = mkIf cfg.enable {
    environment = {
      etc."xdg/qtile/config.py" = mkIf (cfg.configFile != null) { source = cfg.configFile; };
      systemPackages = [ cfg.finalPackage ];
    };

    services = {
      displayManager.sessionPackages = [ cfg.finalPackage ];
      # Recommended by upstream for libqtile/widget/imapwidget.py
      gnome.gnome-keyring.enable = lib.mkDefault true;

      xserver.windowManager.qtile.finalPackage = cfg.package.override {
        extraPackages = cfg.extraPackages cfg.package.pythonModule.pkgs;
      };
    };
  };
}

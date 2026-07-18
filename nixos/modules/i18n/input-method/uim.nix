{
  config,
  lib,
  pkgs,
  ...
}:
let
  imcfg = config.i18n.inputMethod;
  cfg = imcfg.uim;
in
{
  options = {

    i18n.inputMethod.uim = {
      toolbar = lib.mkOption {
        default = "gtk";

        description = ''
          selected UIM toolbar.
        '';

        example = "gtk-systray";

        type = lib.types.enum [
          "gtk"
          "gtk3"
          "gtk-systray"
          "gtk3-systray"
          "qt5"
        ];
      };
    };

  };

  config = lib.mkIf (imcfg.enable && imcfg.type == "uim") {
    environment.variables = {
      GTK_IM_MODULE = "uim";
      QT_IM_MODULE = "uim";
      XMODIFIERS = "@im=uim";
    };

    i18n.inputMethod.package = pkgs.uim;

    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.uim}/bin/uim-xim &
      ${pkgs.uim}/bin/uim-toolbar-${cfg.toolbar} &
    '';
  };
}

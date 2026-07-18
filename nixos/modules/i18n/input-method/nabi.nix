{
  config,
  lib,
  pkgs,
  ...
}:
let
  imcfg = config.i18n.inputMethod;
in
{
  config = lib.mkIf (imcfg.enable && imcfg.type == "nabi") {
    environment.variables = {
      GTK_IM_MODULE = "nabi";
      QT_IM_MODULE = "nabi";
      XMODIFIERS = "@im=nabi";
    };

    i18n.inputMethod.package = pkgs.nabi;
    services.xserver.displayManager.sessionCommands = "${pkgs.nabi}/bin/nabi &";
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.xdg.portal.lxqt;

in
{
  options.xdg.portal.lxqt = {
    enable = lib.mkEnableOption ''
      the desktop portal for the LXQt desktop environment.

      This will add the `lxqt.xdg-desktop-portal-lxqt`
      package (with the extra Qt styles) into the
      {option}`xdg.portal.extraPortals` option
    '';

    styles = lib.mkOption {
      default = [ ];

      description = ''
        Extra Qt styles that will be available to the
        `lxqt.xdg-desktop-portal-lxqt`.
      '';

      example = lib.literalExpression ''
        [
          pkgs.libsForQt5.qtstyleplugin-kvantum
          pkgs.breeze-qt5
        ];
      '';

      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.styles;

    xdg.portal = {
      enable = true;

      extraPortals = [
        (pkgs.lxqt.xdg-desktop-portal-lxqt.override { extraQtStyles = cfg.styles; })
      ];
    };
  };

  meta = {
    teams = [ lib.teams.lxqt ];
  };
}

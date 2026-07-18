{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let
  cfg = config.services.xserver.desktopManager.lxqt;

in

{
  options = {

    environment.lxqt.excludePackages = mkOption {
      default = [ ];
      defaultText = lib.literalExpression "[ ]";
      description = "Which LXQt packages to exclude from the default environment";
      example = lib.literalExpression "with pkgs; [ lxqt.qterminal ]";
      type = with lib.types; listOf package;
    };

    services.xserver.desktopManager.lxqt.enable = mkEnableOption "the LXQt desktop manager";

    services.xserver.desktopManager.lxqt.extraPackages = lib.mkOption {
      default = [ ];
      defaultText = lib.literalExpression "[ ]";
      description = "Extra packages to be installed system wide.";
      example = lib.literalExpression "with pkgs; [ xscreensaver ]";
      type = with lib.types; listOf package;
    };

    services.xserver.desktopManager.lxqt.iconThemePackage =
      lib.mkPackageOption pkgs [ "kdePackages" "breeze-icons" ] { }
      // {
        description = "The package that provides a default icon theme.";
      };

  };

  config = mkIf cfg.enable {

    # Link some extra directories in /run/current-system/software/share
    environment.pathsToLink = [ "/share" ];

    environment.systemPackages =
      pkgs.lxqt.preRequisitePackages
      ++ pkgs.lxqt.corePackages
      ++ [ cfg.iconThemePackage ]
      ++ (utils.removePackagesByName pkgs.lxqt.optionalPackages config.environment.lxqt.excludePackages)
      ++ cfg.extraPackages;

    programs.gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-qt;
    # virtual file systems support for PCManFM-QT
    services.gvfs.enable = mkDefault true;
    services.libinput.enable = mkDefault true;
    services.upower.enable = config.powerManagement.enable;

    services.xserver.desktopManager.session = singleton {
      bgSupport = true;
      name = "lxqt";

      start = ''
        # Upstream installs default configuration files in
        # $prefix/share/lxqt instead of $prefix/etc/xdg, (arguably)
        # giving distributors freedom to ship custom default
        # configuration files more easily. In order to let the session
        # manager find them the share subdirectory is added to the
        # XDG_CONFIG_DIRS environment variable.
        #
        # For an explanation see
        # https://github.com/lxqt/lxqt/issues/1521#issuecomment-405097453
        #
        export XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS''${XDG_CONFIG_DIRS:+:}${config.system.path}/share

        exec ${pkgs.lxqt.lxqt-session}/bin/startlxqt
      '';
    };

    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1050804
    xdg.portal.config.lxqt.default = mkDefault [
      "lxqt"
      "gtk"
    ];

    xdg.portal.lxqt.enable = mkDefault true;
  };

  meta = {
    teams = [ teams.lxqt ];
  };

}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gtklock;
  configFormat = pkgs.formats.ini {
    listToValue = builtins.concatStringsSep ";";
  };

  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkPackageOption
    ;
in
{
  options.programs.gtklock = {
    config = mkOption {
      description = ''
        Configuration for gtklock.
        See [`gtklock(1)`](https://github.com/jovanlanik/gtklock/blob/master/man/gtklock.1.scd) man page for details.
      '';

      example = lib.literalExpression ''
        {
          main = {
            idle-hide = true;
            idle-timeout = 10;
          };
        }'';

      type = configFormat.type;
    };

    enable = mkEnableOption "gtklock, a GTK-based lockscreen for Wayland";
    package = mkPackageOption pkgs "gtklock" { };

    modules = mkOption {
      default = [ ];
      description = "gtklock modules to load.";

      example = lib.literalExpression ''
        with pkgs; [
          gtklock-playerctl-module
          gtklock-powerbar-module
          gtklock-userinfo-module
        ]'';

      type = with types; listOf package;
    };

    style = mkOption {
      default = null;

      description = ''
        CSS Stylesheet for gtklock.
        See [gtklock's wiki](https://github.com/jovanlanik/gtklock/wiki#Styling) for details.
      '';

      type = with types; nullOr lines;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."xdg/gtklock/config.ini".source = configFormat.generate "config.ini" cfg.config;
    environment.systemPackages = [ cfg.package ];

    programs.gtklock.config.main = {
      modules = lib.mkIf (cfg.modules != [ ]) (
        map (pkg: "${pkg}/lib/gtklock/${lib.removePrefix "gtklock-" pkg.pname}.so") cfg.modules
      );

      style = lib.mkIf (cfg.style != null) "${pkgs.writeText "style.css" cfg.style}";
    };

    security.pam.services.gtklock = { };
  };
}

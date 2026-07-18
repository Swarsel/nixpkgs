{
  config,
  lib,
  pkgs,
  ...
}:

let
  enable = config.programs.bash.enableLsColors;
in
{
  options = {
    programs.bash.enableLsColors = lib.mkEnableOption "extra colors in directory listings" // {
      default = true;
    };

    programs.bash.lsColorsFile = lib.mkOption {
      default = null;
      description = "Alternative colorscheme for ls colors";
      example = lib.literalExpression "\${pkgs.dircolors-solarized}/ansi-dark";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf enable {
    programs.bash.promptPluginInit = ''
      eval "$(${pkgs.coreutils}/bin/dircolors -b ${
        lib.optionalString (config.programs.bash.lsColorsFile != null) config.programs.bash.lsColorsFile
      })"
    '';
  };
}

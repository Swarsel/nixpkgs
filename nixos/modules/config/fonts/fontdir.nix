{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.fonts.fontDir;

  x11Fonts = pkgs.callPackage (
    {
      font-alias,
      gzip,
      mkfontscale,
      runCommand,
    }:
    runCommand "X11-fonts"
      {
        nativeBuildInputs = [
          gzip
          mkfontscale
        ];

        preferLocalBuild = true;
      }
      ''
        mkdir -p "$out/share/X11/fonts"
        font_regexp='.*\.\(ttf\|ttc\|otb\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
        find ${toString config.fonts.packages} -regex "$font_regexp" \
          -exec ln -sf -t "$out/share/X11/fonts" '{}' \;
        cd "$out/share/X11/fonts"
        ${lib.optionalString cfg.decompressFonts ''
          gunzip -f *.gz
        ''}
        mkfontscale
        mkfontdir
        cat $(find ${pkgs.font-alias}/ -name fonts.alias) >fonts.alias
      ''
  ) { };

in

{

  imports = [
    (lib.mkRenamedOptionModule [ "fonts" "enableFontDir" ] [ "fonts" "fontDir" "enable" ])
  ];

  options = {
    fonts.fontDir = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to create a directory with links to all fonts in
          {file}`/run/current-system/sw/share/X11/fonts`.
        '';

        type = lib.types.bool;
      };

      decompressFonts = lib.mkOption {
        default = config.programs.xwayland.enable;
        defaultText = lib.literalExpression "config.programs.xwayland.enable";

        description = ''
          Whether to decompress fonts in
          {file}`/run/current-system/sw/share/X11/fonts`.
        '';

        type = lib.types.bool;
      };

    };
  };

  config = lib.mkIf cfg.enable {

    environment.pathsToLink = [ "/share/X11/fonts" ];
    environment.systemPackages = [ x11Fonts ];

    services.xserver.filesSection = ''
      FontPath "${x11Fonts}/share/X11/fonts"
    '';

  };

}

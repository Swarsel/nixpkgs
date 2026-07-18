{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
  symlinkJoin,
  families ? [ ],
}:
let
  allFonts = import ./fonts.nix;
  availableFamilyNames = builtins.attrNames allFonts;
  selectedFamilies = if (families == [ ]) then availableFamilyNames else families;
  unknownFamilies = lib.subtractLists availableFamilyNames families;
  fontsToBuild = lib.filterAttrs (name: _: lib.elem name selectedFamilies) allFonts;
  makeFont =
    font:
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit (font) version;
      pname = lib.toLower (lib.replaceStrings [ " (" ")" " " ] [ "-" "" "-" ] font.name);

      src = fetchzip {
        inherit (font) hash url;
        stripRoot = font.stripRoot or true;
      };

      outputs = [
        "out"
        "webfont"
      ];

      nativeBuildInputs = [ installFonts ];

      # Some fonts, e.g. "ibm-plex-sans-korean" and "ibm-plex-sans-japanese"
      # include both unhinted and hinted variants of the ttf and woff/woff2 type
      # fonts, which collide when using the `installFonts` hook.
      # Default to installing the hinted variant of the fonts.
      #
      # Additionally, fonts with webfonts include complete and split forms.
      # Default to the complete forms.
      preInstall = ''
        find . -type d \( -name unhinted -or -name split \) -exec rm -rf {} +
      '';

      meta = meta // {
        description = font.name;
      };
    });
  fontDerivations = lib.mapAttrs (_: v: makeFont v) fontsToBuild;
  meta = {
    description = "IBM Plex Typeface";
    homepage = "https://www.ibm.com/plex/";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      magicquark
      ners
      romildo
      ryanccn
    ];

    platforms = lib.platforms.all;
  };
in
assert lib.assertMsg (unknownFamilies == [ ]) "Unknown font(s): ${toString unknownFamilies}";
symlinkJoin {
  inherit meta;
  pname = "ibm-plex";
  version = "0-unstable-2026-02-12";
  paths = lib.attrValues fontDerivations;

  passthru = fontDerivations // {
    updateScript = ./update.py;
  };
}

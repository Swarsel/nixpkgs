{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-go";
  version = "1.001";

  src = fetchzip {
    url = "https://carrois.com/downloads/FiraGO/Download_Folder_FiraGO_${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }.zip";

    hash = "sha256-+lw4dh7G/Xv3pzGXdMUl9xNc2Nk7wUOAh+lq3K1LrXs=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = ''
      Font with the same glyph set as Fira Sans 4.3 and additionally
      supports Arabic, Devenagari, Georgian, Hebrew and Thai
    '';

    homepage = "https://carrois.com/fira/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.loicreynier ];
    platforms = lib.platforms.all;
  };
})

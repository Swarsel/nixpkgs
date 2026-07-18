{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "babelstone-han";
  version = "16.0.3";

  src = fetchzip {
    url = "https://babelstone.co.uk/Fonts/Download/BabelStoneHan-${finalAttrs.version}.zip";
    hash = "sha256-HmmRJLs51hoHoKQYdjbiivnJl+RhcBwzkng+5PoqX10=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Unicode CJK font with over 36000 Han characters";
    homepage = "https://www.babelstone.co.uk/Fonts/Han.html";
    license = lib.licenses.arphicpl;
    maintainers = with lib.maintainers; [ emily ];
    platforms = lib.platforms.all;
  };
})

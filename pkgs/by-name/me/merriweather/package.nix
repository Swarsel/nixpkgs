{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "merriweather";
  version = "2.200";

  src = fetchFromGitHub {
    owner = "SorkinType";
    repo = "Merriweather";
    rev = "6e3263d6241aeb747ebfcdd4af3ff8bd1013bb49";
    sha256 = "sha256-mpVJpxI98VxHpZMFFyTHjxTPcUTB1kK8XCGa32znMcQ=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  # TODO: it would be nice to build this from scratch, but lots of
  # Python dependencies to package (fontmake, gftools)
  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Text face designed to be pleasant to read on screens";
    homepage = "https://github.com/SorkinType/Merriweather";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ emily ];
    platforms = lib.platforms.all;
  };
})

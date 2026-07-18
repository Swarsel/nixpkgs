{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vollkorn";
  version = "4.105";

  src = fetchzip {
    url = "http://vollkorn-typeface.com/download/vollkorn-${
      builtins.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }.zip";

    hash = "sha256-oG79GgCwCavbMFAPakza08IPmt13Gwujrkc/NKTai7g=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
    "doc"
  ];

  nativeBuildInputs = [ installFonts ];

  postInstall = ''
    install -Dm444 {Fontlog,OFL-FAQ,OFL}.txt -t $doc/share/doc/${finalAttrs.pname}-${finalAttrs.version}/
  '';

  meta = {
    description = "Free and healthy typeface for bread and butter use";
    homepage = "http://vollkorn-typeface.com/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.schmittlauch ];
    platforms = lib.platforms.all;
  };
})

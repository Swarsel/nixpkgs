{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "unicode-idna";
  version = "17.0.0";

  src = fetchurl {
    url = "https://www.unicode.org/Public/${finalAttrs.version}/idna/IdnaMappingTable.txt";
    hash = "sha256-h/BVBdwCb9sr/xYTK9xoqAFGdYNogqmisYRFQK0744I=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/unicode/idna
    cp -r $src $out/share/unicode/idna/IdnaMappingTable.txt

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Unicode IDNA compatible processing data";
    homepage = "http://www.unicode.org/reports/tr46/";
    license = lib.licenses.unicode-dfs-2016;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
  };
})

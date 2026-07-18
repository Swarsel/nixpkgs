{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ttf-indic";
  version = "0.2";

  src = fetchurl {
    url = "https://www.indlinux.org/downloads/files/indic-otf-${version}.tar.gz";
    hash = "sha256-ZFmg1JanAf3eeF7M+yohrXYSUb0zLgNSFldEMzkhXnI=";
  };

  installPhase = ''
    runHook preInstall

    install -m444 -Dt $out/share/fonts/truetype OpenType/*.ttf

    runHook postInstall
  '';

  meta = {
    description = "Indic Opentype Fonts collection";
    homepage = "https://www.indlinux.org/wiki/index.php/Downloads";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.akssri ];
    platforms = lib.platforms.all;
  };
}

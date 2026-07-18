{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "pecita";
  version = "5.4";

  src = fetchurl {
    url = "https://pecita.eu/b/Pecita.otf";
    hash = "sha256-D9IZ+p4UFHUNt9me7D4vv0x6rMK9IaViKPliCEyX6t4=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype
    cp -v $src $out/share/fonts/opentype/Pecita.otf

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Handwritten font with connected glyphs";
    homepage = "https://pecita.eu/police-en.php";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
}

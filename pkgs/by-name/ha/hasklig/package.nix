{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hasklig";
  version = "1.1";

  src = fetchzip {
    url = "https://github.com/i-tu/Hasklig/releases/download/${version}/Hasklig-${version}.zip";
    hash = "sha256-jsPQtjuegMePt4tB1dZ9mq15LSxXBYwtakbq4od/sko=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -m444 -Dt $out/share/fonts/opentype *.otf

    runHook postInstall
  '';

  meta = {
    description = "Font with ligatures for Haskell code based off Source Code Pro";
    homepage = "https://github.com/i-tu/Hasklig";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ davidrusu ];
    platforms = lib.platforms.all;
  };
}

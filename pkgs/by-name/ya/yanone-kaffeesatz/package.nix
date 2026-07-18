{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "yanone-kaffeesatz";
  version = "2004";

  src = fetchzip {
    url = "https://yanone.de/2015/data/UIdownloads/Yanone%20Kaffeesatz.zip";
    hash = "sha256-8yAB73UJ77/c8/VLqiFeT1KtoBQzOh+vWrI+JA2dCoY=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.otf -t $out/share/fonts/opentype

    runHook postInstall
  '';

  meta = {
    description = "Free font classic";
    homepage = "https://yanone.de/fonts/kaffeesatz/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ mt-caret ];
    platforms = with lib.platforms; all;
  };
}

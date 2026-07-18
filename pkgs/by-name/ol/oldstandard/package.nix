{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "oldstandard";
  version = "2.2";

  src = fetchzip {
    url = "https://github.com/akryukov/oldstand/releases/download/v${version}/${pname}-${version}.otf.zip";
    hash = "sha256-cDB5KJm87DK+GczZ3Nmn4l5ejqViswVbwrJ9XbhEh8I=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -m444 -Dt $out/share/fonts/opentype *.otf
    install -m444 -Dt $out/share/doc/${pname}-${version}    FONTLOG.txt

    runHook postInstall
  '';

  meta = {
    description = "Attempt to revive a specific type of Modern style of serif typefaces";
    homepage = "https://github.com/akryukov/oldstand";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.all;
  };
}

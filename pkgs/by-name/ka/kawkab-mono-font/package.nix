{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "kawkab-mono";
  version = "20151015";

  src = fetchzip {
    url = "https://makkuk.com/kawkab-mono/downloads/kawkab-mono-0.1.zip";
    hash = "sha256-arZTzXj7Ba5G4WF3eZVGNaONhOsYVPih9iBgsN/lg14=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = {
    description = "Arab fixed-width font";
    homepage = "https://makkuk.com/kawkab-mono/";
    license = lib.licenses.ofl;
  };
}

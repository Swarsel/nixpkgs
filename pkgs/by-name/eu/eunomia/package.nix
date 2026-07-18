{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  majorVersion = "0";
  minorVersion = "200";
in
stdenvNoCC.mkDerivation {
  pname = "eunomia";
  version = "${majorVersion}.${minorVersion}";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/eunomia_${majorVersion}${minorVersion}.zip";
    hash = "sha256-Rd2EakaTWjzoEV00tHTgg/bXgJUFfPjCyQUWi7QhFG4=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/opentype $src/*.otf

    runHook postInstall
  '';

  meta = {
    description = "Futuristic decorative font";
    homepage = "https://dotcolon.net/font/eunomia/";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      minijackson
    ];

    platforms = lib.platforms.all;
  };
}

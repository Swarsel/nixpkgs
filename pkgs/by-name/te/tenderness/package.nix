{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  majorVersion = "0";
  minorVersion = "601";
in
stdenvNoCC.mkDerivation {
  pname = "tenderness";
  version = "${majorVersion}.${minorVersion}";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/tenderness_${majorVersion}${minorVersion}.zip";
    hash = "sha256-bwJKW+rY7/r2pBCSA6HYlaRMsI/U8UdW2vV4tmYuJww=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/opentype $src/*.otf

    runHook postInstall
  '';

  meta = {
    description = "Serif font designed by Sora Sagano with old-style figures";
    homepage = "https://dotcolon.net/font/tenderness/";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      minijackson
    ];

    platforms = lib.platforms.all;
  };
}

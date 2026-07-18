{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

let
  majorVersion = "0";
  minorVersion = "200";
in
stdenvNoCC.mkDerivation {
  pname = "ferrum";
  version = "${majorVersion}.${minorVersion}";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/ferrum_${majorVersion}${minorVersion}.zip";
    hash = "sha256-NDJwgFWZgyhMkGRWlY55l2omEw6ju3e3dHCEsWNzQIc=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Decorative font";
    homepage = "https://dotcolon.net/font/ferrum/";
    license = lib.licenses.cc0;

    maintainers = with lib.maintainers; [
      minijackson
    ];

    platforms = lib.platforms.all;
  };
}

{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

let
  majorVersion = "0";
  minorVersion = "102";
in
stdenvNoCC.mkDerivation {
  pname = "aileron";
  version = "${majorVersion}.${minorVersion}";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/aileron_${majorVersion}${minorVersion}.zip";
    hash = "sha256-Ht48gwJZrn0djo1yl6jHZ4+0b710FVwStiC1Zk5YXME=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Helvetica font in nine weights";
    homepage = "https://dotcolon.net/font/aileron/";
    license = lib.licenses.cc0;

    maintainers = with lib.maintainers; [
      minijackson
    ];

    platforms = lib.platforms.all;
  };
}

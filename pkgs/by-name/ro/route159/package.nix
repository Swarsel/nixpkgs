{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

let
  majorVersion = "1";
  minorVersion = "10";
in
stdenvNoCC.mkDerivation {
  pname = "route159";
  version = "${majorVersion}.${minorVersion}";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/route159_${majorVersion}${minorVersion}.zip";
    hash = "sha256-1InyBW1LGbp/IU/ql9mvT14W3MTxJdWThFwRH6VHpTU=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Weighted sans serif font";
    homepage = "https://dotcolon.net/font/route159/";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      minijackson
    ];

    platforms = lib.platforms.all;
  };
}

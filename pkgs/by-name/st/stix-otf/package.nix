{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "stix-otf";
  version = "1.1.1";

  src = fetchzip {
    url = "https://sources.debian.org/src/fonts-stix/1.1.1-4.1/STIXv${version}-word.zip";
    hash = "sha256-M3STue+RPHi8JgZZupV0dVLZYKBiFutbBOlanuKkD08=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Fonts for Scientific and Technical Information eXchange";
    homepage = "http://www.stixfonts.org/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
}

{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "untex";
  version = "1.3";

  src = fetchurl {
    url = "ftp://ftp.thp.uni-duisburg.de/pub/source/untex-${finalAttrs.version}.tar.gz";
    sha256 = "1jww43pl9qvg6kwh4h8imp966fzd62dk99pb4s93786lmp3kgdjv";
  };

  preBuild = ''
    sed -i '1i#include <stdlib.h>\n#include <string.h>' untex.c
    mkdir -p $out/bin $out/share/man/man1
  '';

  hardeningDisable = [ "format" ];

  installFlags = [
    "BINDIR=$(out)/bin"
    "MANDIR=$(out)/share/man/man1"
  ];

  installTargets = [
    "install"
    "install.man"
  ];

  unpackPhase = "tar xf $src";

  meta = {
    description = "Utility which removes LaTeX commands from input";
    homepage = "https://www.ctan.org/pkg/untex";
    license = lib.licenses.gpl1Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "untex";
  };
})

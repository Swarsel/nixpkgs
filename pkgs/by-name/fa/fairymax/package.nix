{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "fairymax";
  version = "4.8";

  src = fetchurl {
    url = "https://home.hccnet.nl/h.g.muller/fmax4_8w.c";
    hash = "sha256-ikn+CA5lxtDYSDT+Nsv1tfORhKW6/vlmHcGAT9SFfQc=";
  };

  # errors by default in GCC 14
  env.NIX_CFLAGS_COMPILE = "-Wno-error=return-mismatch -Wno-error=implicit-int";

  buildPhase = ''
    cc *.c -Wno-return-type \
      -o fairymax \
      -DINI_FILE='"'"$out/share/fairymax/fmax.ini"'"'
  '';

  installPhase = ''
    mkdir -p "$out"/{bin,share/fairymax}
    cp fairymax "$out/bin"
    cp fmax.ini "$out/share/fairymax"
  '';

  ini = fetchurl {
    hash = "sha256-lh2ivXx4jNdWn3pT1WKKNEvkVQ31JfdDx+vqNx44nf8=";
    url = "https://home.hccnet.nl/h.g.muller/fmax.ini";
  };

  unpackPhase = ''
    cp ${src} fairymax.c
    cp ${ini} fmax.ini
  '';

  meta = {
    description = "Small chess engine supporting fairy pieces";

    longDescription = ''
      A version of micro-Max that reads the piece description from a file
      fmax.ini, so that arbitrary fairy pieces can be implemented. This version
      (4.8J) supports up to 15 piece types, and board sizes up to 12x8.
    '';

    homepage = "http://home.hccnet.nl/h.g.muller/dwnldpage.html";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.all;
    mainProgram = "fairymax";
  };
}

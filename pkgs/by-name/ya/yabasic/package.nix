{
  lib,
  stdenv,
  fetchurl,
  libffi,
  libsm,
  libx11,
  libxt,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yabasic";
  version = "2.91.4";

  src = fetchurl {
    url = "https://www.yabasic.de/download/yabasic-${finalAttrs.version}.tar.gz";
    hash = "sha256-3JUTNOFmZpSlAx40BHAT6YQgYLxdVPPXLwyfzDoYdlc=";
  };

  buildInputs = [
    libsm
    libx11
    libxt
    libffi
    ncurses
  ];

  meta = {
    description = "Yet another BASIC";

    longDescription = ''
      Yabasic is a traditional basic-interpreter. It comes with goto and various
      loops and allows to define subroutines and libraries. It does simple
      graphics and printing. Yabasic can call out to libraries written in C and
      allows to create standalone programs. Yabasic runs under Unix and Windows
      and has a comprehensive documentation; it is small, simple, open-source
      and free.
    '';

    homepage = "http://2484.de/yabasic/";
    changelog = "https://2484.de/yabasic/whatsnew.html";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "yabasic";
  };
})

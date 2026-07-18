{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "n2048";
  version = "0.1";

  src = fetchurl {
    url = "https://www.dettus.net/n2048/n2048_v${finalAttrs.version}.tar.gz";
    hash = "sha256-c4bHWmdQuwyRXIm/sqw3p71pMv6VLAzIuUTaDHIWn6A=";
  };

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-function-declaration"
    ];
  };

  preInstall = ''
    mkdir -p "$out"/{share/man,bin}
  '';

  meta = {
    description = "Console implementation of 2048 game";
    homepage = "http://www.dettus.net/n2048/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "n2048";
  };
})

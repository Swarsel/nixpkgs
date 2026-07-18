{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxrandr,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "x2vnc";
  version = "1.7.2";

  src = fetchurl {
    url = "https://fredrik.hubbe.net/x2vnc/x2vnc-${finalAttrs.version}.tar.gz";
    sha256 = "00bh9j3m6snyd2fgnzhj5vlkj9ibh69gfny9bfzlxbnivb06s1yw";
  };

  buildInputs = [
    libx11
    xorgproto
    libxext
    libxrandr
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu89";
  hardeningDisable = [ "format" ];

  meta = {
    description = "Program to control a remote VNC server";
    homepage = "http://fredrik.hubbe.net/x2vnc.html";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "x2vnc";
  };
})

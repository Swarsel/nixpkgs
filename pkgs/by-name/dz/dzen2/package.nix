{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxft,
  libxinerama,
  libxpm,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dzen2";
  version = "0.9.5";

  src = fetchurl {
    url = "https://github.com/robm/dzen/tarball/master/dzen2-${finalAttrs.version}git.tar.gz";
    sha256 = "d4f7943cd39dc23fd825eb684b49dc3484860fa8443d30b06ee38af72a53b556";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxft
    libxinerama
    libxpm
  ];

  buildPhase = ''
    mkdir -p $out/bin $out/man/man1
    make clean install
    cd gadgets
    make clean install
  '';

  patchPhase = ''
    CFLAGS=" -Wall -Os ''${INCS} -DVERSION=\"''${VERSION}\" -DDZEN_XINERAMA -DDZEN_XPM -DDZEN_XFT `pkg-config --cflags xft`"
    LIBS=" -L/usr/lib -lc -lXft -lXpm -lXinerama -lX11"
    echo "CFLAGS=$CFLAGS" >>config.mk
    echo "LIBS=$LIBS" >>config.mk
    echo "LDFLAGS=$LIBS" >>config.mk
    substituteInPlace config.mk --replace /usr/local "$out"
    substituteInPlace gadgets/config.mk --replace /usr/local "$out"
  '';

  meta = {
    description = "X notification utility";
    homepage = "https://github.com/robm/dzen";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})

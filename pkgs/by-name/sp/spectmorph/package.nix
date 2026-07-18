{
  lib,
  stdenv,
  fetchurl,
  cairo,
  fftwFloat,
  glib,
  libao,
  libjack2,
  libsndfile,
  lv2,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spectmorph";
  version = "0.6.1";

  src = fetchurl {
    url = "https://github.com/swesterfeld/spectmorph/releases/download/${finalAttrs.version}/spectmorph-${finalAttrs.version}.tar.bz2";
    hash = "sha256-H/PaczAkjxeu2Q6S/jazZ0PU9oCmhBzsLgbGLusxXm8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libjack2
    lv2
    glib
    qt5.qtbase
    libao
    cairo
    libsndfile
    fftwFloat
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Allows to analyze samples of musical instruments, and to combine them (morphing) to construct hybrid sounds";
    homepage = "https://spectmorph.org";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
})

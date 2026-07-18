{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  fftwFloat,
  libjack2,
  liblo,
  libsndfile,
  lv2,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "padthv1";
  version = "1.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/padthv1/padthv1-${finalAttrs.version}.tar.gz";
    hash = "sha256-Cuq1I18Nc6VCOgwnYzCj13lKjHGzQadWvJCGY4cJQWI=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    libjack2
    alsa-lib
    libsndfile
    liblo
    lv2
    qt5.qtbase
    qt5.qttools
    fftwFloat
  ];

  meta = {
    description = "Polyphonic additive synthesizer";
    homepage = "http://padthv1.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "padthv1_jack";
  };
})

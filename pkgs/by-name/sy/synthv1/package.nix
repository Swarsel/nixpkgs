{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  libjack2,
  liblo,
  lv2,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "synthv1";
  version = "1.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/synthv1/synthv1-${finalAttrs.version}.tar.gz";
    hash = "sha256-eoW1Yl/v1LsdvcQen7/LLDt5Q9Yd4kwX3W+CIjQEfYE=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail  '"''${CONFIG_PREFIX}/''${CMAKE_INSTALL_LIBDIR}"' '"''${CMAKE_INSTALL_LIBDIR}"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    libjack2
    alsa-lib
    liblo
    lv2
  ];

  meta = {
    description = "Old-school 4-oscillator subtractive polyphonic synthesizer with stereo fx";
    homepage = "https://synthv1.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "synthv1_jack";
  };
})

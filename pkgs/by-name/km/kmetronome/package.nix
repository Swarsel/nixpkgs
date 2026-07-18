{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  pandoc,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kmetronome";
  version = "1.4.1";

  src = fetchurl {
    url = "mirror://sourceforge/kmetronome/${finalAttrs.version}/kmetronome-${finalAttrs.version}.tar.bz2";
    hash = "sha256-FJVmSMu0KDoq8DHRxxGyHQQflPCvH1h+WdsV9wcPAPA=";
  };

  nativeBuildInputs = [
    cmake
    pandoc
    pkg-config
    qt6Packages.qttools
  ];

  buildInputs = [
    alsa-lib
    qt6Packages.drumstick
    qt6Packages.qtbase
    qt6Packages.qtsvg
  ];

  dontWrapQtApps = true;

  meta = {
    description = "ALSA MIDI metronome with Qt interface";
    homepage = "https://kmetronome.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "kmetronome";
  };
})

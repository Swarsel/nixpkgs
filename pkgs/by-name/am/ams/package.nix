{
  lib,
  stdenv,
  alsa-lib,
  autoreconfHook,
  fetchgit,
  fftw,
  ladspa-header,
  libjack2,
  pkg-config,
  qt5,
  zita-alsa-pcmi,
}:

stdenv.mkDerivation {
  pname = "ams";
  version = "unstable-2019-04-27";

  src = fetchgit {
    url = "https://git.code.sf.net/p/alsamodular/ams.git";
    rev = "3250bbcfea331c4fcb9845305eebded80054973d";
    sha256 = "0qdyz5llpa94f3qx1xi1mz97vl5jyrj1mqff28p5g9i5rxbbk8z9";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    ladspa-header
    libjack2
    fftw
    zita-alsa-pcmi
  ]
  ++ (with qt5; [
    qtbase
    qttools
  ]);

  meta = {
    description = "Realtime modular synthesizer for ALSA";
    homepage = "https://alsamodular.sourceforge.net";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ sjfloat ];
    platforms = lib.platforms.linux;
    mainProgram = "ams";
  };
}

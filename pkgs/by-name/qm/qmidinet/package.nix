{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  libjack2,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qmidinet";
  version = "1.0.2";

  src = fetchurl {
    url = "mirror://sourceforge/qmidinet/qmidinet-${finalAttrs.version}.tar.gz";
    hash = "sha256-gBAaK32rabujVsCIOJcNZluaKpFz1KjICcRbKgvmXaQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    alsa-lib
    libjack2
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "MIDI network gateway application that sends and receives MIDI data (ALSA Sequencer and/or JACK MIDI) over the network";
    homepage = "http://qmidinet.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "qmidinet";
  };
})

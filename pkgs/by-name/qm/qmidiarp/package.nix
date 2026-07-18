{
  lib,
  stdenv,
  alsa-lib,
  autoreconfHook,
  fetchgit,
  libjack2,
  lv2,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qmidiarp";
  version = "0.7.1";

  src = fetchgit {
    url = "https://git.code.sf.net/p/qmidiarp/code";
    rev = "qmidiarp-${finalAttrs.version}";
    sha256 = "sha256-xTDI1QtgOOMexzFKvYWhlfpXv8uXaoD4o+G6XF8/Cw8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    lv2
    libjack2
  ]
  ++ (with qt5; [
    qttools
  ]);

  meta = {
    description = "Advanced MIDI arpeggiator";

    longDescription = ''
      An advanced MIDI arpeggiator, programmable step sequencer and LFO for Linux.
      It can hold any number of arpeggiator, sequencer, or LFO modules running in
      parallel.
    '';

    homepage = "https://qmidiarp.sourceforge.net";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ sjfloat ];
    platforms = lib.platforms.linux;
    mainProgram = "qmidiarp";
  };
})

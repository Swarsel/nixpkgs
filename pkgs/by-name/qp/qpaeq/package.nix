{
  lib,
  stdenv,
  makeDesktopItem,
  pulseaudio,
  python3,
  qt5,
}:

let
  desktopItem = makeDesktopItem {
    categories = [
      "AudioVideo"
      "Audio"
      "Mixer"
    ];

    desktopName = "qpaeq";
    exec = "@out@/bin/qpaeq";
    genericName = "Audio equalizer";
    icon = "audio-volume-high";
    name = "qpaeq";
    startupNotify = false;
  };
in
stdenv.mkDerivation {
  inherit (pulseaudio) version src;
  pname = "qpaeq";
  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  buildInputs = [
    (python3.withPackages (
      ps: with ps; [
        pyqt5
        dbus-python
      ]
    ))
  ];

  installPhase = ''
    runHook preInstall
    install -D ./src/utils/qpaeq $out/bin/qpaeq
    install -D ${desktopItem}/share/applications/qpaeq.desktop $out/share/applications/qpaeq.desktop
    runHook postInstall
  '';

  preFixup = ''
    sed "s|,sip|,PyQt5.sip|g" -i $out/bin/qpaeq
    wrapQtApp $out/bin/qpaeq
    sed "s|@out@|$out|g" -i $out/share/applications/qpaeq.desktop
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Equalizer interface for pulseaudio's equalizer sinks";
    homepage = "http://www.pulseaudio.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "qpaeq";
  };
}

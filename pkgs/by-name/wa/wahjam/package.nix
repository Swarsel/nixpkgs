{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  libogg,
  libresample,
  libsForQt5,
  libvorbis,
  makeDesktopItem,
  pkg-config,
  portaudio,
  portmidi,
}:

stdenv.mkDerivation {
  pname = "wahjam";
  version = "1.3.1-unstable-2023-05-30";

  src = fetchFromGitHub {
    owner = "wahjam";
    repo = "wahjam";
    rev = "4fde74da3be1fa53cdc2d3bc4b577b40951d6809";
    hash = "sha256-WYfLQxToyjAE+R2eaBKpDJGfkvrOTza8a6JbN9AL3aE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtkeychain
    libogg
    libvorbis
    libresample
    portaudio
    portmidi
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/scalable/apps

    cp qtclient/wahjam $out/bin/wahjam
    cp qtclient/net.jammr.jammr.svg $out/share/icons/hicolor/scalable/apps

    runHook postInstall
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "AudioVideo" ];
      comment = "Play with musicians over the internet";
      desktopName = "Wahjam";
      exec = "wahjam";
      icon = "net.jammr.jammr";
      name = "wahjam";
    })
  ];

  meta = {
    description = "Software for musicians to play together over the internet";
    homepage = "https://github.com/wahjam/wahjam";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ caseyavila ];
    platforms = lib.platforms.linux;
    mainProgram = "wahjam";
  };
}

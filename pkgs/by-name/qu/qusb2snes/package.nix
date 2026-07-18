{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  qt6,
  enableGui ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qusb2snes";
  version = "0.7.35";

  src = fetchFromGitHub {
    owner = "Skarsnik";
    repo = "QUsb2snes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-521L4awWr4L2W12vAZUMheq4plXUXKYo4d3S6AfHgPA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    installShellFiles
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebsockets
    qt6.qtserialport
  ];

  installPhase = ''
    runHook preInstall
    installBin QUsb2Snes
    installManPage --name QUsb2Snes.1 QUsb2Snes.manpage.1
    install -Dm644 ui/icons/cheer128x128.png $out/share/icons/hicolor/128x128/apps/fr.nyo.QUsb2Snes.png
    install -Dm644 QUsb2Snes.desktop $out/share/applications/fr.nyo.QUsb2Snes.desktop
    runHook postInstall
  '';

  qmakeFlags = [
    "QUsb2snes.pro"
    "CONFIG+=release"
  ]
  ++ lib.optional (!enableGui) "QUSB2SNES_NOGUI=1";

  meta = {
    description = "Websocket server that provides a unified protocol for accessing SNES (or SNES emulators) software";
    homepage = "https://skarsnik.github.io/QUsb2snes/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ alexland7219 ];
    platforms = lib.platforms.linux;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "QUsb2Snes";
  };
})

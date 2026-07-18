{
  lib,
  stdenv,
  fetchFromGitLab,
  copyDesktopItems,
  libsForQt5,
  makeDesktopItem,
}:

let
  version = "0.3.3";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutentr";

  src = fetchFromGitLab {
    owner = "BoltsJ";
    repo = "cuteNTR";
    tag = version;
    hash = "sha256-KfnC9R38qSMhQDeaMBWm1HoO3Wzs5kyfPFwdMZCWw4E=";
  };

  nativeBuildInputs = [
    libsForQt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    libsForQt5.qtbase
  ];

  buildPhase = ''
    runHook preBuild
    qmake
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r cutentr $out/bin

    install -m 444 -D setup/gui/com.gitlab.BoltsJ.cuteNTR.svg $out/share/icons/hicolor/scalable/apps/cutentr.svg
    runHook postInstall
  '';

  desktopItems = lib.singleton (makeDesktopItem {
    categories = [ "Game" ];
    desktopName = "cuteNTR";
    exec = "cutentr";
    icon = "cutentr";
    name = "cuteNTR";
  });

  meta = {
    description = "3DS streaming client for Linux";
    homepage = "https://gitlab.com/BoltsJ/cuteNTR";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.EarthGman ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cutentr";
  };
}

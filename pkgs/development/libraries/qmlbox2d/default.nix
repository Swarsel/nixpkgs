{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qtbase,
  qtdeclarative,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "qml-box2d";
  version = "0-unstable-2025-09-30";

  src = fetchFromGitHub {
    owner = "qml-box2d";
    repo = "qml-box2d";
    rev = "e3674e0fe030c406a1d915e47eab760624fffa55";
    hash = "sha256-kxDSPO2ifffJng9rKgEwdKRoP6alnYWwItbvE1t4Hbo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    qtbase
    qtdeclarative
  ];

  dontWrapQtApps = true;

  passthru = {
    updateScript = unstableGitUpdater {
      hardcodeZeroVersion = true;
    };
  };

  meta = {
    description = "QML plugin for Box2D engine";
    homepage = "https://github.com/qml-box2d/qml-box2d";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ guibou ];
    platforms = lib.platforms.linux;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  libsForQt5,
  sqlite,
}:

stdenv.mkDerivation {
  pname = "pegasus-frontend";
  version = "0-unstable-2024-11-11";

  src = fetchFromGitHub {
    owner = "mmatyas";
    repo = "pegasus-frontend";
    rev = "54362976fd4c6260e755178d97e9db51f7a896af";
    hash = "sha256-DqtkvDg0oQL9hGB+6rNXe3sDBywvnqy9N31xfyl6nbI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs =
    (with libsForQt5; [
      qtbase
      qtmultimedia
      qtsvg
      qtgraphicaleffects
      qtx11extras
    ])
    ++ [
      sqlite
      SDL2
    ];

  meta = {
    description = "Cross platform, customizable graphical frontend for launching emulators and managing your game collection";
    homepage = "https://pegasus-frontend.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ tengkuizdihar ];
    platforms = lib.platforms.linux;
    mainProgram = "pegasus-fe";
  };
}

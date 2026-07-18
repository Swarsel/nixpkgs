{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linvstmanager";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Goli4thus";
    repo = "linvstmanager";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K6eugimMy/MZgHYkg+zfF8DDqUuqqoeymxHtcFGu2Uk=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
  ];

  meta = {
    description = "Graphical companion application for various bridges like LinVst, etc";
    homepage = "https://github.com/Goli4thus/linvstmanager";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ GabrielDougherty ];
    platforms = lib.platforms.linux;
    mainProgram = "linvstmanager";
  };
})

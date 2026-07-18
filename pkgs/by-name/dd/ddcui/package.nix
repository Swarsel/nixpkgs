{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ddcutil,
  libsForQt5,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ddcui";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "rockowitz";
    repo = "ddcui";
    rev = "v${version}";
    sha256 = "sha256-KcivAoPV/4TihVkwYgq3bWWhG5E8enVSD3bhObl++I0=";
  };

  nativeBuildInputs = [
    # Using cmake instead of the also-supported qmake because ddcui's qmake
    # file is not currently written to support PREFIX installations.
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qttools
    ddcutil
  ];

  meta = {
    description = "Graphical user interface for ddcutil - control monitor settings";
    homepage = "https://www.ddcutil.com/ddcui_main/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ nh2 ];
    platforms = with lib.platforms; linux;
    mainProgram = "ddcui";
  };
}

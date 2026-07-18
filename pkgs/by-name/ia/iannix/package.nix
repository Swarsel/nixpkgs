{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  libsForQt5,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "iannix";
  version = "unstable-2020-12-09";

  src = fetchFromGitHub {
    owner = "buzzinglight";
    repo = "IanniX";
    rev = "287b51d9b90b3e16ae206c0c4292599619f7b159";
    sha256 = "AhoP+Ok78Vk8Aee/RP572hJeM8O7v2ZTvFalOZZqRy8=";
  };

  nativeBuildInputs = [
    pkg-config
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    libsForQt5.qtbase
    libsForQt5.qtscript
  ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];
  qmakeFlags = [ "PREFIX=/" ];

  meta = {
    description = "Graphical open-source sequencer";
    homepage = "https://www.iannix.org/";
    license = lib.licenses.lgpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "iannix";
  };
}

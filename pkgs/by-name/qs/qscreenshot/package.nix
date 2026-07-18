{
  lib,
  stdenv,
  cmake,
  fetchgit,
  libsForQt5,
}:

stdenv.mkDerivation {
  pname = "qscreenshot";
  version = "unstable-2021-10-18";

  src = fetchgit {
    url = "https://git.code.sf.net/p/qscreenshot/code";
    rev = "e340f06ae2f1a92a353eaa68e103d1c840adc12d";
    sha256 = "0mdiwn74vngiyazr3lq72f3jnv5zw8wyd2dw6rik6dbrvfs69jig";
  };

  postPatch = ''
    substituteInPlace qScreenshot/{CMakeLists.txt,cmake/modules/version.cmake} \
      --replace-fail "cmake_minimum_required( VERSION 3.2.0 )" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtx11extras
  ];

  preConfigure = "cd qScreenshot";

  meta = {
    description = "Simple creation and editing of screenshots";
    homepage = "https://sourceforge.net/projects/qscreenshot/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.all;
    mainProgram = "qScreenshot";
    # last successful hydra build on darwin was in 2019
    broken = stdenv.hostPlatform.isDarwin;
  };
}

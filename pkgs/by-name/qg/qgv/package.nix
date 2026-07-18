{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  graphviz,
  jrl-cmakemodules,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qgv";
  version = "1.3.6";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = "qgv";
    rev = "v${finalAttrs.version}";
    hash = "sha256-602+CQAScZPNkuudwbRS1NJYYSoQCDwcRJcj8cS/10Q=";
  };

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qttools
  ];

  propagatedBuildInputs = [
    graphviz
    jrl-cmakemodules
  ];

  meta = {
    description = "Interactive Qt graphViz display";
    homepage = "https://github.com/gepetto/qgv";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.nim65s ];
    platforms = lib.platforms.unix;
  };
})

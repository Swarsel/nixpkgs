{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  lxqt-build-tools,
  qtbase,
  qttools,
  wrapQtAppsHook,
  version ? "2.4.0",
}:

stdenv.mkDerivation rec {
  inherit version;
  pname = "qtermwidget";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "qtermwidget";
    rev = version;

    hash =
      {
        "1.4.0" = "sha256-wYUOqAiBjnupX1ITbFMw7sAk42V37yDz9SrjVhE4FgU=";
        "2.4.0" = "sha256-fTE39goab0md0koS28gRiQgnEumtR5/vTKgpM/wuCrk=";
      }
      ."${version}";
  };

  postPatch = lib.optionals (version == "1.4.0") ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Terminal emulator widget for Qt, used by QTerminal";
    homepage = "https://github.com/lxqt/qtermwidget";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; unix;
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.lxqt ];
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libconfig,
  lxqt-build-tools,
  pkg-config,
  qtbase,
  qttools,
  qtx11extras,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "compton-conf";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "compton-conf";
    rev = version;
    hash = "sha256-GNS0GdkQOEFQHCeXFVNDdT35KCRhfwmkL78tpY71mz0=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    pkg-config
    qttools
    qtx11extras
    wrapQtAppsHook
  ];

  buildInputs = [
    libconfig
    qtbase
  ];

  preConfigure = ''
    substituteInPlace autostart/CMakeLists.txt \
      --replace-fail "DESTINATION \"\''${LXQT_ETC_XDG_DIR}" "DESTINATION \"etc/xdg"
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "GUI configuration tool for compton X composite manager";
    homepage = "https://github.com/lxqt/compton-conf";
    license = lib.licenses.lgpl21Plus;
    platforms = with lib.platforms; unix;
    mainProgram = "compton-conf";
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.lxqt ];
  };
}

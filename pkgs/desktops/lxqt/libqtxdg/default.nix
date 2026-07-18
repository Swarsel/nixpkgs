{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  lxqt-build-tools,
  qtbase,
  qtsvg,
  wrapQtAppsHook,
  version ? "4.4.0",
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libqtxdg";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "libqtxdg";
    tag = finalAttrs.version;

    hash =
      {
        "3.12.0" = "sha256-y+3noaHubZnwUUs8vbMVvZPk+6Fhv37QXUb//reedCU=";
        "4.4.0" = "sha256-9Hj5RnPWtqRkzhrAuXoHnMAQloFbnF/8koPT8ExfSAs=";
      }
      ."${finalAttrs.version}";
  };

  postPatch = lib.optionals (version == "3.12.0") ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
  ];

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DQTXDGX_ICONENGINEPLUGIN_INSTALL_PATH=$out/$qtPluginPrefix/iconengines"
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"
    )
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Qt implementation of freedesktop.org xdg specs";
    homepage = "https://github.com/lxqt/libqtxdg";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libdbusmenu-lxqt,
  libfm-qt,
  libqtxdg,
  lxqt-build-tools,
  qtbase,
  qtsvg,
  qttools,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxqt-qtplugin";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-qtplugin";
    tag = finalAttrs.version;
    hash = "sha256-Ax12jHeNTyEI+2dYj9aW8S6wzDVKN+I9U7ufhx6rycQ=";
  };

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail "DESTINATION \"\''${QT_PLUGINS_DIR}" "DESTINATION \"$qtPluginPrefix"
  '';

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    libdbusmenu-lxqt
    libfm-qt
    libqtxdg
    qtbase
    qtsvg
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "LXQt Qt platform integration plugin";
    homepage = "https://github.com/lxqt/lxqt-qtplugin";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
})

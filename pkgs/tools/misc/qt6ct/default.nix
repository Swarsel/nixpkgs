{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6ct";
  version = "0.11";

  src = fetchFromGitLab {
    owner = "trialuser";
    repo = "qt6ct";
    tag = finalAttrs.version;
    hash = "sha256-aQmqLpM0vogMsYaDS9OeKVI3N53uY4NBC4FF10hK8Uw=";
    domain = "www.opencode.net";
  };

  nativeBuildInputs = [
    cmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwayland
  ];

  cmakeFlags = [
    (lib.cmakeFeature "PLUGINDIR" "${placeholder "out"}/${qtbase.qtPluginPrefix}")
  ];

  meta = {
    description = "Qt6 Configuration Tool";
    homepage = "https://www.opencode.net/trialuser/qt6ct";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      Flakebi
      Scrumplex
    ];

    platforms = lib.platforms.linux;
    mainProgram = "qt6ct";
  };
})

{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libcprime,
  libcsys,
  lm_sensors,
  ninja,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corestats";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "corestats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4wVBC/NeexJIFsDOjqHFC/u3Rapd/22fjH5yMVafWPY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    lm_sensors
    libcprime
    libcsys
  ];

  meta = {
    description = "System resource viewer from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/corestats";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "corestats";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  gitUpdater,
  mpv,
  ninja,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpc-qt";
  version = "26.01";

  src = fetchFromGitHub {
    owner = "mpc-qt";
    repo = "mpc-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tgCdPzolUlp3Cy1ZbDlMQvl/4WcTl86QTZ8F18f0JME=";
  };

  nativeBuildInputs = [
    boost
    ninja
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    mpv
  ];

  cmakeFlags = [
    "-DMPCQT_VERSION=${finalAttrs.version}"
  ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = "master";
    rev-prefix = "v";
  };

  meta = {
    description = "Media Player Classic Qute Theater";
    homepage = "https://mpc-qt.github.io";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "mpc-qt";
    broken = stdenv.hostPlatform.isDarwin;
  };
})

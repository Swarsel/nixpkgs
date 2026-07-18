{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  gitUpdater,
  graphviz,
  gst_all_1,
  perl,
  pkg-config,
  sox,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pocketsphinx";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "cmusphinx";
    repo = "pocketsphinx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bB/k1KRrdP52MN5iZr2Q2MGWh0JOCsqJxccUyVu2Va0=";
  };

  outputs = [
    "out"
    "data"
    "dev"
    "lib"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    pkg-config
  ];

  buildInputs = [ gst_all_1.gstreamer ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_GSTREAMER" true)
    (lib.cmakeFeature "CMAKE_INSTALL_DATADIR" "${placeholder "data"}/share")
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    perl
    sox
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = gitUpdater {
      ignoredVersions = "rc";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Small speech recognizer";
    homepage = "https://github.com/cmusphinx/pocketsphinx";
    changelog = "https://github.com/cmusphinx/pocketsphinx/blob/v${finalAttrs.version}/NEWS";

    license =
      with lib.licenses;
      AND [
        bsd2
        bsd3
        mit
      ];

    maintainers = with lib.maintainers; [ jopejoe1 ];
    mainProgram = "pocketsphinx";
    pkgConfigModules = [ "pocketsphinx" ];
  };
})

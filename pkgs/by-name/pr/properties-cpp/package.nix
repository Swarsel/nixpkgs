{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  doxygen,
  gitUpdater,
  graphviz,
  gtest,
  lomiri,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "properties-cpp";
  version = "0.0.4";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/lib-cpp/properties-cpp";
    rev = finalAttrs.version;
    hash = "sha256-rxv2SPTXubaIBlDZixBZ88wqM7pxY03dVhRVImcDZtA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    pkg-config
  ];

  buildInputs = [
    lomiri.cmake-extras
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkInputs = [
    gtest
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Very simple convenience library for handling properties and signals in C++11";
    homepage = "https://gitlab.com/ubports/development/core/lib-cpp/properties-cpp";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ edwtjo ];
    platforms = lib.platforms.linux;

    pkgConfigModules = [
      "properties-cpp"
    ];
  };
})

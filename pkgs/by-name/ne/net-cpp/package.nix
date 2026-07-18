{
  lib,
  stdenv,
  fetchFromGitLab,
  boost,
  cmake,
  curl,
  doxygen,
  gitUpdater,
  graphviz,
  gtest,
  jsoncpp,
  lomiri,
  makeFontsConf,
  pkg-config,
  process-cpp,
  properties-cpp,
  python3,
  testers,
  validatePkgConfig,
  writableTmpDirAsHomeHook,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      httpbin
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "net-cpp";
  version = "3.2.2";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/lib-cpp/net-cpp";
    tag = finalAttrs.version;
    hash = "sha256-6isbPSzoPcnqbv6+ju/Arbcy+PgFxFF376d4CGmQ6wM=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    validatePkgConfig
    writableTmpDirAsHomeHook # makes doc generation quieter
  ];

  buildInputs = [
    boost
    curl
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_WERROR" true)
  ];

  env.FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };
  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    pkg-config
    pythonEnv
  ];

  checkInputs = [
    lomiri.cmake-extras
    gtest
    jsoncpp
    process-cpp
    properties-cpp
  ];

  # Tests start HTTP server in separate process with fixed URL, parallelism breaks things
  enableParallelChecking = false;

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Simple yet beautiful networking API for C++11";
    homepage = "https://gitlab.com/ubports/development/core/lib-cpp/net-cpp";
    changelog = "https://gitlab.com/ubports/development/core/lib-cpp/net-cpp/-/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;

    pkgConfigModules = [
      "net-cpp"
    ];

    teams = [ lib.teams.lomiri ];
  };
})

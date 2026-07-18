{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  cmake-extras,
  dbus,
  dbus-test-runner,
  gitUpdater,
  glib,
  gtest,
  libqtdbustest,
  lomiri-api,
  pkg-config,
  qtbase,
  testers,
}:

let
  withQt6 = lib.versions.major qtbase.version == "6";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gmenuharness";
  version = "0.1.6";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/gmenuharness";
    rev = finalAttrs.version;
    hash = "sha256-H6nwpvS4zK7uR3LspGQD03+CSc67oPaZeQyeAJh03zs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cmake-extras
    glib
    lomiri-api
  ];

  cmakeFlags = [
    (lib.strings.cmakeBool "enable_tests" finalAttrs.finalPackage.doCheck)
  ]
  ++ lib.optionals finalAttrs.finalPackage.doCheck [
    (lib.strings.cmakeBool "ENABLE_QT6" withQt6)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    dbus
    dbus-test-runner
  ];

  checkInputs = [
    gtest
    libqtdbustest
    qtbase
  ];

  checkPhase = ''
    runHook preCheck

    dbus-test-runner -t make -p test -p "''${enableParallelChecking:+-j $NIX_BUILD_CORES}"

    runHook postCheck
  '';

  dontWrapQtApps = true;
  enableParallelChecking = false;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Library to test GMenuModel structures";
    homepage = "https://gitlab.com/ubports/development/core/gmenuharness";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "libgmenuharness"
    ];

    teams = [ lib.teams.lomiri ];
  };
})

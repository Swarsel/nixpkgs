{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  cmake-extras,
  dbus,
  dbus-test-runner,
  fetchpatch,
  gitUpdater,
  gtest,
  pkg-config,
  procps,
  python3,
  qtbase,
  testers,
}:

let
  withQt6 = lib.versions.major qtbase.version == "6";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libqtdbustest";
  version = "0.4.1";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/libqtdbustest";
    rev = finalAttrs.version;
    hash = "sha256-bTLGL/3iy8Wu4HnPRJj2Vn3xOlPhXFbaxgyQol8Y1JY=";
  };

  patches = [
    # Disable QProcess start timeout
    (fetchpatch {
      hash = "sha256-ThDbn6URvkj5ARDMj+xO0fb1Qh2YQRzVy24O03KglHI=";
      url = "https://salsa.debian.org/ubports-team/libqtdbustest/-/raw/debian/0.3.2-3/debian/patches/1003_no-QProcess-waitForstarted-timeout.patch";
    })

    # More robust dbus address reading
    (fetchpatch {
      hash = "sha256-hq8pdducp/udxoGWGt1dgL/7VHcbJO/oT1dOY1zew8M=";
      url = "https://salsa.debian.org/ubports-team/libqtdbustest/-/raw/debian/0.3.2-3/debian/patches/1004_make-reading-address-from-dbus-daemon-more-robust.patch";
    })
  ];

  postPatch = lib.optionalString (!finalAttrs.finalPackage.doCheck) ''
    # Don't build tests when we're not running them
    sed -i -e '/add_subdirectory(tests)/d' CMakeLists.txt
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cmake-extras
    qtbase
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_QT6" withQt6)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    dbus
    dbus-test-runner
    procps
    (python3.withPackages (
      ps: with ps; [
        python-dbusmock
      ]
    ))
  ];

  checkInputs = [
    gtest
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
    description = "Library for testing DBus interactions using Qt";
    homepage = "https://gitlab.com/ubports/development/core/libqtdbustest";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "qdbus-simple-test-runner";

    pkgConfigModules = [
      "libqtdbustest-${if withQt6 then "qt6" else "1"}"
    ];

    teams = [ lib.teams.lomiri ];
  };
})

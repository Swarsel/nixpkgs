{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  callPackage,
  catch2_3,
  cmake,
  kdePackages,
  libsForQt5,
  nixosTests,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sfxr-qt";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "agateau";
    repo = "sfxr-qt";
    rev = finalAttrs.version;
    hash = "sha256-JAWDk7mGkPtQ5yaA6UT9hlAy770MHrTBhBP9G8UqFKg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    (python3.withPackages (
      pp: with pp; [
        pyyaml
        jinja2
        setuptools
      ]
    ))
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtquickcontrols2
    SDL
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_CATCH2" true)
  ];

  doCheck = true;

  checkInputs = [
    catch2_3
  ];

  passthru.tests = {
    export-square-wave = callPackage ./test-export-square-wave { };
    sfxr-qt-starts = nixosTests.sfxr-qt;
  };

  meta = {
    description = "Sound effect generator, QtQuick port of sfxr";
    homepage = "https://github.com/agateau/sfxr-qt";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
    mainProgram = "sfxr-qt";
  };
})

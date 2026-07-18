{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  check,
  fetchpatch,
  flex,
  gitUpdater,
  gmp,
  gtk3,
  libsForQt5,
  pkg-config,
  withGUI ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpsolve";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "robol";
    repo = "MPSolve";
    rev = "de7ebfc7afc4834a0c9f92a04be7abdf5943d446";
    hash = "sha256-BGXvNxWUbto0yMIpEIxZ9wOYv9w0ev4OgVcniNYIKoU=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-ODWpp966S1SsSN8hf7yuYgJR44GgbLwSxui280WWGmM=";
      name = "include-cmath-in-c++-before-defining-isnan-macro.patch";
      url = "https://github.com/robol/MPSolve/commit/260432c9d1002261f60159d0520af7862d4471ed.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    pkg-config
  ]
  ++ lib.optionals withGUI [
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    gmp
  ]
  ++ lib.optionals withGUI [
    gtk3
    libsForQt5.qtbase
  ];

  configureFlags = [
    (lib.enableFeature withGUI "graphical-debugger")
    (lib.enableFeature withGUI "ui")
  ];

  doCheck = true;
  checkInputs = [ check ];
  checkTarget = "check";
  enableParallelBuilding = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Multiprecision Polynomial Solver";
    homepage = "https://numpi.dm.unipi.it/scientific-computing-libraries/mpsolve/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kilianar ];
    mainProgram = "mpsolve";
  };
})

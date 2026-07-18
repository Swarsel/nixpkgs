{
  lib,
  stdenv,
  fetchFromGitHub,
  gsl,
  libpng,
  libsForQt5,
  libsndfile,
  lzo,
  nix-update-script,
  runCommand,
  writableTmpDirAsHomeHook,
  ocl-icd ? null,
  opencl-clhpp ? null,
  withOpenCL ? true,
}:

assert withOpenCL -> opencl-clhpp != null;
assert withOpenCL -> ocl-icd != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "mandelbulber";
  version = "2.33";

  src = fetchFromGitHub {
    owner = "buddhi1980";
    repo = "mandelbulber2";
    rev = finalAttrs.version;
    sha256 = "sha256-3PPgH9E+k2DFm8ib1bmvTsllQ9kYi3oLDwPHcs1Otac=";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
    libsForQt5.qttools
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    libpng
    gsl
    libsndfile
    lzo
  ]
  ++ lib.optionals withOpenCL [
    opencl-clhpp
    ocl-icd
  ];

  qmakeFlags = [
    "SHARED_PATH=${placeholder "out"}"
    (if withOpenCL then "qmake/mandelbulber-opencl.pro" else "qmake/mandelbulber.pro")
  ];

  sourceRoot = "${finalAttrs.src.name}/mandelbulber2";

  passthru = {
    tests = {
      test = runCommand "mandelbulber2-test" {
        nativeBuildInputs = [
          finalAttrs.finalPackage
          writableTmpDirAsHomeHook
        ];
      } "mandelbulber2 --test && touch $out";
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "3D fractal rendering engine";
    longDescription = "Mandelbulber creatively generates three-dimensional fractals. Explore trigonometric, hyper-complex, Mandelbox, IFS, and many other 3D fractals.";
    homepage = "https://mandelbulber.com";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kovirobi ];
    platforms = lib.platforms.linux;
    mainProgram = "mandelbulber2";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  gfortran,
  lapack,
  mctc-lib,
  meson,
  mstore,
  multicharge,
  ninja,
  pkg-config,
  python3,
  buildType ? "meson",
}:

assert !blas.isILP64 && !lapack.isILP64;
assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

stdenv.mkDerivation (finalAttrs: {
  pname = "dftd4";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "dftd4";
    repo = "dftd4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uKjNOIza3/I0oREp88oFESoNqEdumo1AztIjcrVb1O8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix pkg-config, meson and cmake paths for include and lib dirs
    ./build-paths.patch
  ];

  postPatch = ''
    patchShebangs --build \
      config/install-mod.py \
      app/tester.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gfortran
    pkg-config
    python3
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optional (buildType == "cmake") cmake;

  buildInputs = [
    blas
    lapack
  ];

  propagatedBuildInputs = [
    mctc-lib
    mstore
    multicharge
  ];

  cmakeFlags = [
    (lib.strings.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  doCheck = true;
  __structuredAttrs = true;

  meta = {
    description = "Generally Applicable Atomic-Charge Dependent London Dispersion Correction";
    homepage = "https://github.com/grimme-lab/dftd4";
    changelog = "https://github.com/dftd4/dftd4/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      lgpl3Plus
      gpl3Plus
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
    mainProgram = "dftd4";
  };
})

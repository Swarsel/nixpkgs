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
  pname = "multicharge";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "multicharge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hswqC+fvC6tuxDpuUgowyqm72ubVikzpR4EzXtTM5cs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix wrong generation of package config include paths
    ./pkgconfig.patch
  ];

  postPatch = ''
    patchShebangs --build config/install-mod.py

    # custom blas and lapack need to be explicitly found for transitive dependencies
    # otherwise CMAKE builds can not proceed.
    echo 'set(custom-blas_FOUND TRUE)' >> config/cmake/Findcustom-blas.cmake
    echo 'set(custom-lapack_FOUND TRUE)' >> config/cmake/Findcustom-lapack.cmake
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
  ++ lib.optionals (buildType == "cmake") [
    cmake
  ];

  buildInputs = [
    blas
    lapack
  ];

  propagatedBuildInputs = [
    mctc-lib
    mstore
  ];

  doCheck = true;
  __structuredAttrs = true;

  meta = {
    description = "Electronegativity equilibration model for atomic partial charges";
    homepage = "https://github.com/grimme-lab/multicharge";
    changelog = "https://github.com/grimme-lab/multicharge/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
    mainProgram = "multicharge";
  };
})

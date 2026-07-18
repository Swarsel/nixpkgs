{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  dftd4,
  gfortran,
  lapack,
  mctc-lib,
  meson,
  mstore,
  multicharge,
  ninja,
  pkg-config,
  python3,
  simple-dftd3,
  toml-f,
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
  pname = "tblite";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "tblite";
    repo = "tblite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z0g+bf6APqNLB9mDE49FelitQ9ptZXdFQuYeXIT0NIw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-fix-multicharge-dep-needed-for-static-compilation.patch

    # Fix wrong paths in pkg-config file
    ./pkgconfig.patch
  ];

  postPatch =
    # Python scripts in test subdirectories to run the tests
    ''
      patchShebangs ./
    ''

    # libquadmath is only shipped by GCC on architectures that lack native
    # quad-precision support (e.g. x86_64); on aarch64 it does not exist.
    + lib.optionalString (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) ''
      substituteInPlace config/meson.build \
        --replace-fail "lib_deps += cc.find_library('quadmath')" ""
    '';

  strictDeps = true;

  nativeBuildInputs = [
    gfortran
    pkg-config
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
    mctc-lib
    mstore
    toml-f
    multicharge
    dftd4
    simple-dftd3
  ];

  doCheck = buildType == "meson";

  nativeCheckInputs = [
    # Runs python test drivers (test/*/tester.py) during checkPhase, so it must be available on the
    # build host (strictDeps)
    python3
  ];

  checkFlags = [
    "-j1" # Tests hang when multiple are run in parallel
  ];

  __structuredAttrs = true;

  meta = {
    description = "Light-weight tight-binding framework";
    homepage = "https://github.com/tblite/tblite";
    changelog = "https://github.com/tblite/tblite/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
    mainProgram = "tblite";
  };
})

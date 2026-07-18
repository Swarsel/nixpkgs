{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  libspatialindex,
  mpi,
  mpiCheckPhaseHook,
  ninja,
  testers,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsupermesh";
  version = "2026.0";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "libsupermesh";
    tag = finalAttrs.version;
    hash = "sha256-f/5y3XherRbN/Eq3tfivrOHByF8LAXtYN3v9Vx82m8Q=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    mpi
    gfortran
    cmake
    ninja
    validatePkgConfig
  ];

  buildInputs = [
    libspatialindex
    gfortran.cc.lib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  # On aarch64-darwin platform, the test program segfault at the line
  # https://github.com/firedrakeproject/libsupermesh/blob/09af7c9a3beefc715fbdc23e46fdc96da8169ff6/src/tests/test_parallel_p1_inner_product_2d.F90#L164
  # in defining the lambda subroutine pack_data_b with variable field_b.
  # This error is test source and compiler related and does not indicate broken functionality of libsupermesh.
  doCheck = !(stdenv.hostPlatform.system == "aarch64-darwin");
  nativeCheckInputs = [ mpiCheckPhaseHook ];
  __darwinAllowLocalNetworking = true;

  passthru = {
    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    description = "Parallel supermeshing library";
    homepage = "https://github.com/firedrakeproject/libsupermesh";
    changelog = "https://github.com/firedrakeproject/libsupermesh/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libsupermesh" ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  fetchpatch2,
  gfortran,
  hypre,
  lapack,
  llvmPackages,
  mpi,
  mpiCheckPhaseHook,
  pkg-config,
  testers,
  isILP64 ? false,
  mpiSupport ? true,
  precision ? "double",
}:

assert lib.elem precision [
  "single"
  "double"
  "long-double"
];

stdenv.mkDerivation (finalAttrs: {
  pname = "hypre";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "hypre-space";
    repo = "hypre";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zu9YWfBT2WJxPg6JHrXjZWRM9Ai1p28EpvAx6xfdPsY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchpatch2 {
      hash = "sha256-Ni5xlfFmok884x5Hctf9VOsAgZp8ICG7QNVGTdVKPzE=";
      url = "https://raw.githubusercontent.com/spack/spack-packages/eb4b23847f0079d0c9c8de99aaa32557ad4c9194/repos/builtin/packages/hypre/hypre-precision-fix.patch?full_index=1";
    })
  ];

  # fix sequence check
  postPatch = lib.optionalString (!mpiSupport) ''
    substituteInPlace src/test/CMakeLists.txt \
      --replace-fail ''\'''${MPIEXEC_EXECUTABLE} ''${MPIEXEC_NUMPROC_FLAG} 1' ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    gfortran
  ];

  propagatedBuildInputs = [
    (blas.override { inherit isILP64; })
    (lapack.override { inherit isILP64; })
  ]
  ++ lib.optional mpiSupport mpi
  ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
    (lib.cmakeBool "HYPRE_ENABLE_HYPRE_BLAS" false)
    (lib.cmakeBool "HYPRE_ENABLE_HYPRE_LAPACK" false)
    (lib.cmakeBool "HYPRE_ENABLE_FORTRAN" true)
    (lib.cmakeBool "HYPRE_ENABLE_BIGINT" isILP64)
    (lib.cmakeBool "HYPRE_ENABLE_SINGLE" (precision == "single"))
    (lib.cmakeBool "HYPRE_ENABLE_LONG_DOUBLE" (precision == "long-double"))
    (lib.cmakeBool "HYPRE_ENABLE_OPENMP" true)
    (lib.cmakeBool "HYPRE_ENABLE_MPI" mpiSupport)
    (lib.cmakeBool "HYPRE_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;
  nativeCheckInputs = lib.optional mpiSupport mpiCheckPhaseHook;

  postInstall = lib.optionalString finalAttrs.finalPackage.doCheck ''
    rm -rf $out/bin
  '';

  __darwinAllowLocalNetworking = mpiSupport;
  cmakeDir = "../src";

  passthru = {
    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        moduleNames = [ "HYPRE" ];
        package = finalAttrs.finalPackage;
      };

      ilp64 = hypre.override { isILP64 = true; };
      serial = hypre.override { mpiSupport = false; };
      single = hypre.override { precision = "single"; };
    };
  };

  meta = {
    description = "Parallel solvers for sparse linear systems featuring multigrid methods";
    homepage = "https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      mkez
      qbisi
    ];

    platforms = lib.platforms.unix;
  };
})

{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  blas,
  cmake,
  gfortran,
  lapack,
  llvmPackages,
  metis,
  mpi,
  mpiCheckPhaseHook,
  # passthru.tests
  mpich,
  parmetis,
  pkg-config,
  superlu_dist,
  isILP64 ? false,
  # Todo: ask for permission of unfree parmetis
  withParmetis ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "superlu_dist";
  version = "9.2.0";

  src = fetchFromGitHub {
    owner = "xiaoyeli";
    repo = "superlu_dist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i/Gg+9oMNNRlviwXUSRkWNaLRZLPWZRtA1fGYqh2X0k=";
    # Remove non‐free files.
    postFetch = "rm $out/SRC/prec-independent/mc64ad_dist.c";
  };

  patches = [
    ./mc64ad_dist-stub.patch
  ];

  # --oversubscribe unrecognized by mpich
  # see https://github.com/xiaoyeli/superlu_dist/issues/208
  postPatch = ''
    substituteInPlace TEST/CMakeLists.txt \
      --replace-fail "-oversubscribe" ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    gfortran
  ];

  buildInputs = [
    mpi
    # always build with lp64 BLAS/LAPACK.
    # see https://github.com/xiaoyeli/superlu_dist/issues/132#issuecomment-2323093701
    (blas.override { isILP64 = false; })
    (lapack.override { isILP64 = false; })
  ]
  ++ lib.optionals withParmetis [
    metis
    parmetis
  ]
  ++ lib.optionals stdenv.cc.isClang [
    gfortran.cc.lib
    llvmPackages.openmp
  ];

  cmakeFlags = [
    (lib.cmakeBool "enable_examples" false)
    (lib.cmakeBool "enable_openmp" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_STATIC_LIBS" stdenv.hostPlatform.isStatic)
    (lib.cmakeBool "XSDK_ENABLE_Fortran" true)
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
    (lib.cmakeBool "TPL_ENABLE_INTERNAL_BLASLIB" false)
    (lib.cmakeBool "TPL_ENABLE_LAPACKLIB" true)
    (lib.cmakeBool "TPL_ENABLE_PARMETISLIB" withParmetis)
    (lib.cmakeFeature "XSDK_INDEX_SIZE" (if isILP64 then "64" else "32"))
  ]
  ++ lib.optionals withParmetis [
    (lib.cmakeFeature "TPL_PARMETIS_LIBRARIES" "-lmetis -lparmetis")
    (lib.cmakeFeature "TPL_PARMETIS_INCLUDE_DIRS" "${lib.getDev parmetis}/include")
  ];

  doCheck = true;
  nativeCheckInputs = [ mpiCheckPhaseHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  passthru = {
    inherit isILP64;

    tests = {
      ilp64 = superlu_dist.override { isILP64 = true; };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      mpich = superlu_dist.override {
        mpi = mpich;
      };
    };
  };

  meta = {
    description = "Library for the solution of large, sparse, nonsymmetric systems of linear equations";
    homepage = "https://portal.nersc.gov/project/sparse/superlu/";

    license = with lib.licenses; [
      # Files: *
      # Lawrence Berkeley National Labs BSD variant license
      bsd3Lbnl

      # Files: SRC/prec-independent/symbfact.c
      # Xerox code; actually `Boehm-GC` variant.
      mit

      # Files: SRC/include/*colamd.h
      # University of Florida code; permissive COLAMD licence.
      free

      # Files: SRC/include/wingetopt.*
      # Microsoft code; Obtained from https://github.com/iotivity/iotivity/tree/master/resource/c_common/windows.
      asl20
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})

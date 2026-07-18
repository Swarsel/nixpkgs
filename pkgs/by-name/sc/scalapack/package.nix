{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  gfortran,
  lapack,
  mpi,
  mpiCheckPhaseHook,
  testers,
}:

assert blas.isILP64 == lapack.isILP64;

stdenv.mkDerivation (finalAttrs: {
  pname = "scalapack";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "Reference-ScaLAPACK";
    repo = "scalapack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cUdHC9DfJBSrxFVyCSSj9qxE5a+JFkI1W671iT7DP1M=";
  };

  outputs = [
    "out"
    "dev"
  ];

  # The xssep, xsgsep, and xsyevr tests need to be disabled for ILP64
  patches = lib.optional finalAttrs.passthru.isILP64 ./disable-tests-ilp64.patch;

  # Required to activate ILP64.
  # See https://github.com/Reference-ScaLAPACK/scalapack/pull/19
  postPatch = lib.optionalString finalAttrs.passthru.isILP64 ''
    sed -i 's/INTSZ = 4/INTSZ = 8/g'   TESTING/traditional/EIG/* TESTING/traditional/LIN/*
    sed -i 's/INTGSZ = 4/INTGSZ = 8/g' TESTING/traditional/EIG/* TESTING/traditional/LIN/*
  '';

  nativeBuildInputs = [
    cmake
    gfortran
  ];

  propagatedBuildInputs = [
    blas
    lapack
    mpi
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeFeature "LAPACK_LIBRARIES" "-llapack")
    (lib.cmakeFeature "BLAS_LIBRARIES" "-lblas")
    (lib.cmakeFeature "CMAKE_C_FLAGS" "${lib.concatStringsSep " " [
      "-Wno-implicit-function-declaration"
      (lib.optionalString finalAttrs.passthru.isILP64 "-DInt=long")
    ]}")
  ]
  ++ lib.optionals finalAttrs.passthru.isILP64 [
    (lib.cmakeFeature "CMAKE_Fortran_FLAGS" "-fdefault-integer-8")
  ];

  # xslu and xsllt tests seem to time out on x86_64-darwin.
  # this line is left so those who force installation on x86_64-darwin can still build
  doCheck = !(stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isDarwin);
  nativeCheckInputs = [ mpiCheckPhaseHook ];
  # Increase individual test timeout from 1500s to 10000s because hydra's builds
  # sometimes fail due to this
  checkFlags = [ "ARGS=--timeout 10000" ];
  __structuredAttrs = true;

  passthru = {
    inherit (blas) isILP64;

    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Library of high-performance linear algebra routines for parallel distributed memory machines";
    homepage = "http://www.netlib.org/scalapack/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      costrouc
      markuskowa
      gdinh
    ];

    platforms = lib.platforms.unix;
    # xslu and xsllt tests fail on x86 darwin
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64;
    pkgConfigModules = [ "scalapack" ];
  };
})

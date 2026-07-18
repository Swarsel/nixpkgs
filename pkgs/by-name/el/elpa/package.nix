{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  blas,
  config,
  cudaPackages,
  lapack,
  mpi,
  mpiCheckPhaseHook,
  perl,
  scalapack,
  avx2Support ? stdenv.hostPlatform.avx2Support,
  avx512Support ? stdenv.hostPlatform.avx512Support,
  # CPU optimizations
  avxSupport ? stdenv.hostPlatform.avxSupport,
  # Enable NIVIA GPU support
  # Note, that this needs to be built on a system with a GPU
  # present for the tests to succeed.
  enableCuda ? config.cudaSupport,
  # type of GPU architecture
  nvidiaArch ? "sm_60",
}:

assert blas.isILP64 == lapack.isILP64;
assert blas.isILP64 == scalapack.isILP64;

stdenv.mkDerivation (finalAttrs: {
  pname = "elpa";
  version = "2026.02.002";

  src = fetchurl {
    url = "https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/${finalAttrs.version}/elpa-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-AuPFn+xTzY62akzBX6T78ZDPllQiciP7itVXE+lCeTI=";
  };

  outputs = [
    "out"
    "doc"
    "man"
    "dev"
  ];

  patches = [
    # Use a plain name for the pkg-config file
    ./pkg-config.patch
  ];

  postPatch = ''
    patchShebangs ./fdep/fortran_dependencies.pl
    patchShebangs ./test-driver

    # Fix the test script generator
    substituteInPlace Makefile.am --replace '#!/bin/bash' '#!${stdenv.shell}'
  '';

  nativeBuildInputs = [
    autoreconfHook
    perl
  ]
  ++ lib.optionals enableCuda [ cudaPackages.cuda_nvcc ];

  buildInputs = [
    mpi
    blas
    lapack
    scalapack
  ]
  ++ lib.optionals enableCuda [
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
  ];

  configureFlags = [
    "--with-mpi"
    "--enable-openmp"
    "--without-threading-support-check-during-build"
  ]
  ++ lib.optional blas.isILP64 "--enable-64bit-integer-math-support"
  ++ lib.optional (!avxSupport) "--disable-avx"
  ++ lib.optional (!avx2Support) "--disable-avx2"
  ++ lib.optional (!avx512Support) "--disable-avx512"
  ++ lib.optional (!stdenv.hostPlatform.isx86_64) "--disable-sse"
  ++ lib.optional (!stdenv.hostPlatform.isx86_64) "--disable-sse-assembly"
  ++ lib.optional stdenv.hostPlatform.isx86_64 "--enable-sse-assembly"
  ++ lib.optionals enableCuda [
    "--enable-nvidia-gpu"
    "--with-NVIDIA-GPU-compute-capability=${nvidiaArch}"
  ];

  preConfigure = ''
    export FC="mpifort"
    export CC="mpicc"
    export CXX="mpicxx"
    export CPP="cpp"

    # These need to be set for configure to succeed
    export FCFLAGS="${
      lib.optionalString stdenv.hostPlatform.isx86_64 "-msse3 "
      + lib.optionalString avxSupport "-mavx "
      + lib.optionalString avx2Support "-mavx2 -mfma "
      + lib.optionalString avx512Support "-mavx512"
    }"

    export CFLAGS=$FCFLAGS
  '';

  doCheck = !enableCuda;
  nativeCheckInputs = [ mpiCheckPhaseHook ];

  preCheck = ''
    #patchShebangs ./

    # Reduce test problem sizes
    export TEST_FLAGS="1500 50 16"
  '';

  enableParallelBuilding = true;
  passthru = { inherit (blas) isILP64; };

  meta = {
    description = "Eigenvalue Solvers for Petaflop-Applications";
    homepage = "https://elpa.mpcdf.mpg.de/";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
  };
})

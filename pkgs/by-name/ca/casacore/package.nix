{
  lib,
  stdenv,
  fetchFromGitHub,
  adios2,
  bison,
  blas,
  cfitsio,
  cmake,
  fftw,
  fftwFloat,
  flex,
  gfortran,
  gsl,
  hdf5,
  lapack,
  llvmPackages,
  mpi,
  readline,
  wcslib,
  adios2Support ? false,
  hdf5Support ? false,
  mpiSupport ? false,
}:
let
  casacorePackages = {
    adios2 = adios2.override {
      inherit mpi mpiSupport;
    };

    fftw = fftw.override {
      inherit mpi;
      enableMpi = mpiSupport;
    };

    fftwFloat = fftwFloat.override {
      inherit mpi;
      enableMpi = mpiSupport;
    };

    hdf5 = hdf5.override {
      inherit mpi mpiSupport;
      cppSupport = !mpiSupport;
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "casacore";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "casacore";
    repo = "casacore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NOxuHMCuHGk9XuWXMwQTN6kOFDI0QuHMgfNRDdlPw44=";
  };

  patches = [
    # Fix the generated .pc file: set Requires from a variable instead of
    # leaving it empty, and remove hardcoded absolute cmake build paths from
    # Cflags (which would embed /nix/store paths from the build environment).
    ./casacore-pkgconfig.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gfortran
    flex
    bison
  ]
  ++ lib.optional mpiSupport mpi;

  buildInputs = [
    blas
    lapack
    casacorePackages.fftw
    casacorePackages.fftwFloat
    readline
    gsl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.openmp
  ];

  propagatedBuildInputs = [
    wcslib
    cfitsio
  ]
  ++ lib.optional hdf5Support casacorePackages.hdf5
  ++ lib.optional mpiSupport mpi
  ++ lib.optional adios2Support casacorePackages.adios2;

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_PYTHON3" false)
    (lib.cmakeBool "USE_OPENMP" true)
    (lib.cmakeBool "USE_ADIOS2" adios2Support)
    (lib.cmakeBool "USE_HDF5" hdf5Support)
    (lib.cmakeBool "USE_MPI" mpiSupport)
    (lib.cmakeBool "PORTABLE" true)
    (lib.cmakeBool "USE_PCH" false)
    (lib.cmakeBool "BUILD_FFTPACK_DEPRECATED" true) # Needed for casacpp
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Upstream probes this flag, but it fails on darwin, so pass it explicitly
    (lib.cmakeFeature "CMAKE_Fortran_FLAGS" "-fallow-argument-mismatch")
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Suite of C++ libraries for radio astronomy data processing";
    homepage = "https://casacore.github.io/casacore/";
    changelog = "https://github.com/casacore/casacore/blob/master/CHANGES.md";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ kiranshila ];
    platforms = lib.platforms.all;
  };
})

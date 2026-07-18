{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  config,
  cudaPackages,
  dbcsr,
  dftd4,
  elpa,
  fftw,
  gfortran,
  gmp,
  greenx,
  gsl,
  hdf5-fortran-mpi,
  jonquil,
  lapack,
  libint,
  libvdwxc,
  libvori,
  libxc_7,
  libxsmm,
  makeWrapper,
  mctc-lib,
  mpi,
  mpiCheckPhaseHook,
  mstore,
  multicharge,
  newScope,
  pkg-config,
  plumed,
  python3,
  rocmPackages,
  scalapack,
  simple-dftd3,
  sirius,
  spfft,
  spglib,
  spla,
  tblite,
  test-drive,
  toml-f,
  trexio,
  which,
  zlib,
  cudaTarget ? "80",
  enableElpa ? false,
  gpuBackend ? (
    if config.cudaSupport then
      "cuda"
    else if config.rocmSupport then
      "rocm"
    else
      "none"
  ),
  # Change to a value suitable for your target GPU.
  # see https://github.com/cp2k/cp2k/blob/master/CMakeLists.txt#L433
  hipTarget ? "gfx908",
}:

assert builtins.elem gpuBackend [
  "none"
  "cuda"
  "rocm"
];

let
  grimmeCmake = lib.makeScope newScope (self: {
    dftd4 = dftd4.override {
      inherit (self) mstore mctc-lib multicharge;
      buildType = "cmake";
    };

    jonquil = jonquil.override {
      inherit (self) toml-f test-drive;
      buildType = "cmake";
    };

    mctc-lib = mctc-lib.override {
      inherit (self) jonquil;
      buildType = "cmake";
    };

    mstore = mstore.override {
      inherit (self) mctc-lib;
      buildType = "cmake";
    };

    multicharge = multicharge.override {
      inherit (self) mctc-lib mstore;
      buildType = "cmake";
    };

    simple-dftd3 = simple-dftd3.override {
      inherit (self) mctc-lib mstore toml-f;
      buildType = "cmake";
    };

    sirius = sirius.override {
      inherit (self)
        mctc-lib
        toml-f
        multicharge
        dftd4
        simple-dftd3
        ;
    };

    tblite = tblite.override {
      inherit (self)
        mctc-lib
        mstore
        toml-f
        multicharge
        dftd4
        simple-dftd3
        ;

      buildType = "cmake";
    };

    test-drive = test-drive.override { buildType = "cmake"; };

    toml-f = toml-f.override {
      inherit (self) test-drive;
      buildType = "cmake";
    };
  });

in
stdenv.mkDerivation (finalAttrs: {
  pname = "cp2k";
  version = "2026.1-unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "cp2k";
    repo = "cp2k";
    rev = "c28f603b5956aa638ef130b21b091da4e3a17639";
    hash = "sha256-LIghR2gCYbJDux4bFfeKCi+a+VDVbjcZfcVpYwjPkEg=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Remove the build command line from the source.
    # This avoids dependencies to .dev inputs
    ./remove-compiler-options.patch

    # Fix pkg-config path generation
    ./pkgconfig.patch
  ];

  postPatch = ''
    patchShebangs tools exts/dbcsr/tools/build_utils exts/dbcsr/.cp2k
  '';

  strictDeps = true;

  nativeBuildInputs = [
    python3
    cmake
    which
    makeWrapper
    pkg-config
    gfortran
    mpi
  ]
  ++ lib.optionals (gpuBackend == "cuda") [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    fftw
    gsl
    libint
    libvori
    libxc_7
    libxsmm
    mpi
    spglib
    scalapack
    blas
    lapack
    dbcsr
    plumed
    zlib
    hdf5-fortran-mpi
    spla
    spfft
    libvdwxc
    trexio
    greenx
    gmp
    grimmeCmake.dftd4
    grimmeCmake.simple-dftd3
    grimmeCmake.tblite
    grimmeCmake.sirius
    grimmeCmake.toml-f
  ]
  ++ lib.optional enableElpa elpa
  ++ lib.optionals (gpuBackend == "cuda") [
    cudaPackages.cuda_cudart
    cudaPackages.libcufft
    cudaPackages.libcublas
    cudaPackages.cuda_nvrtc
  ]
  ++ lib.optionals (gpuBackend == "rocm") [
    rocmPackages.clr
    rocmPackages.rocm-core
    rocmPackages.hipblas
    rocmPackages.hipfft
    rocmPackages.rocblas
  ];

  propagatedBuildInputs = [ (lib.getBin mpi) ];

  cmakeFlags = [
    (lib.strings.cmakeBool "CP2K_USE_DFTD4" true)
    (lib.strings.cmakeBool "CP2K_USE_TBLITE" true)
    (lib.strings.cmakeBool "CP2K_USE_FFTW3" true)
    (lib.strings.cmakeBool "CP2K_USE_HDF5" true)
    (lib.strings.cmakeBool "CP2K_USE_LIBINT2" true)
    (lib.strings.cmakeBool "CP2K_USE_LIBXC" true)
    (lib.strings.cmakeBool "CP2K_USE_MPI" true)
    (lib.strings.cmakeBool "CP2K_USE_VORI" true)
    (lib.strings.cmakeBool "CP2K_USE_TREXIO" true)
    (lib.strings.cmakeBool "CP2K_USE_SPGLIB" true)
    (lib.strings.cmakeBool "CP2K_USE_SPLA" true)
    (lib.strings.cmakeBool "CP2K_USE_LIBXSMM" true)
    (lib.strings.cmakeBool "CP2K_USE_SIRIUS" true)
    (lib.strings.cmakeBool "CP2K_USE_LIBVDWXC" true)
    (lib.strings.cmakeBool "CP2K_USE_PLUMED" true)
    (lib.strings.cmakeBool "CP2K_USE_GREENX" true)
    (lib.strings.cmakeBool "CP2K_USE_ELPA" enableElpa)
    (lib.strings.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ]
  ++ lib.optionals (gpuBackend == "rocm") [
    (lib.strings.cmakeFeature "CP2K_USE_ACCEL" "HIP")
    (lib.strings.cmakeFeature "CMAKE_HIP_ARCHITECTURES" hipTarget)
  ]
  ++ lib.optionals (gpuBackend == "cuda") [
    (lib.strings.cmakeFeature "CP2K_USE_ACCEL" "CUDA")
    (lib.strings.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaTarget)
  ];

  nativeCheckInputs = [
    mpiCheckPhaseHook
  ];

  postInstall = ''
    mkdir -p $out/share/cp2k
    cp -r ../data/* $out/share/cp2k

    for i in $out/bin/*; do
      wrapProgram $i \
        --set-default CP2K_DATA_DIR $out/share/cp2k \
        --set-default OMP_NUM_THREADS 1
    done
  '';

  doInstallCheck = gpuBackend == "none";

  installCheckPhase = ''
    runHook preInstallCheck

    for TEST in $out/bin/{dbt_tas,dbt,libcp2k,parallel_rng_types,gx_ac}_unittest.psmp; do
      mpirun -n 2 $TEST
    done

    runHook postInstallCheck
  '';

  __structuredAttrs = true;
  propagatedUserEnvPkgs = [ mpi ];

  passthru = {
    inherit mpi;
  };

  meta = {
    description = "Quantum chemistry and solid state physics program";
    homepage = "https://www.cp2k.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = [ "x86_64-linux" ];
  };
})

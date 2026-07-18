{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  boost,
  cmake,
  config,
  costa,
  ctestCheckHook,
  cudaPackages,
  dftd4,
  eigen,
  gfortran,
  gsl,
  hdf5,
  jonquil,
  lapack,
  libvdwxc,
  libxc,
  llvmPackages,
  mctc-lib,
  mpi,
  mpiCheckPhaseHook,
  multicharge,
  pkg-config,
  rocmPackages,
  scalapack,
  simple-dftd3,
  spfft,
  spglib,
  spla,
  toml-f,
  umpire,
  enablePython ? false,
  gpuBackend ? (
    if config.cudaSupport then
      "cuda"
    else if config.rocmSupport then
      "rocm"
    else
      "none"
  ),
  pythonPackages ? null,
}:

assert builtins.elem gpuBackend [
  "none"
  "cuda"
  "rocm"
];
assert enablePython -> pythonPackages != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "SIRIUS";
  version = "7.10.0";

  src = fetchFromGitHub {
    owner = "electronic-structure";
    repo = "SIRIUS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cq4ajtAJXfIH1B866FYhgROMSwd7nsbXf/6kbSwJAso=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gfortran
    mpi
    pkg-config
  ]
  ++ lib.optionals (gpuBackend == "cuda") [ cudaPackages.cuda_nvcc ]
  ++ lib.optionals enablePython [ pythonPackages.python ];

  buildInputs = [
    blas
    lapack
    gsl
    libxc
    hdf5
    umpire
    mpi
    spglib
    spfft
    spla
    costa
    scalapack
    boost
    eigen
    libvdwxc
    jonquil
    simple-dftd3
    dftd4
    mctc-lib
    toml-f
    multicharge
  ]
  ++ lib.optionals (gpuBackend == "cuda") [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_profiler_api
    cudaPackages.cuda_nvtx
    cudaPackages.libcufft
    cudaPackages.libcusolver
    cudaPackages.libcublas
  ]
  ++ lib.optionals (gpuBackend == "rocm") [
    rocmPackages.clr
    rocmPackages.rocblas
    rocmPackages.rocsolver
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.openmp
  ]
  ++ lib.optionals enablePython (
    with pythonPackages;
    [
      python
      pybind11
    ]
  );

  propagatedBuildInputs = [
    (lib.getBin mpi)
  ]
  ++ lib.optionals enablePython (
    with pythonPackages;
    [
      mpi4py
      voluptuous
      numpy
      h5py
      scipy
      pyyaml
    ]
  );

  cmakeFlags = [
    "-DSIRIUS_USE_SCALAPACK=ON"
    "-DSIRIUS_USE_VDWXC=ON"
    "-DSIRIUS_CREATE_FORTRAN_BINDINGS=ON"
    "-DSIRIUS_USE_OPENMP=ON"
    "-DSIRIUS_USE_DFTD3=ON"
    "-DSIRIUS_USE_DFTD4=ON"
    "-DBUILD_TESTING=ON"
  ]
  ++ lib.optionals (gpuBackend == "cuda") [
    "-DSIRIUS_USE_CUDA=ON"
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ]
  ++ lib.optionals (gpuBackend == "rocm") [
    "-DSIRIUS_USE_ROCM=ON"
    "-DHIP_ROOT_DIR=${rocmPackages.clr}"
  ]
  ++ lib.optionals enablePython [
    "-DSIRIUS_CREATE_PYTHON_MODULE=ON"
  ];

  env.CXXFLAGS = toString [
    # GCC 13: error: 'uintptr_t' in namespace 'std' does not name a type
    "-include cstdint"
  ];

  doCheck = !umpire.passthru.rocmSupport;

  nativeCheckInputs = [
    mpiCheckPhaseHook
    ctestCheckHook
  ];

  # Can not run parallel checks generally as it requires exactly multiples of 4 MPI ranks
  # Even cpu_serial tests had to be disabled as they require scalapack routines in the sandbox
  # and run into the same problem as MPI tests
  checkFlags = [
    "--label-exclude"
    "integration_test"
  ];

  __structuredAttrs = true;

  meta = {
    description = "Domain specific library for electronic structure calculations";
    homepage = "https://github.com/electronic-structure/SIRIUS";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})

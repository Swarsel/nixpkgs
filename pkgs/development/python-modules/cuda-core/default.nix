{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  cffi,
  cloudpickle,
  config,
  # build-system
  cuda-bindings,
  # passthru
  cuda-core,
  cuda-pathfinder,
  cudaPackages,
  cython,
  # dependencies
  numpy,
  psutil,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  symlinkJoin,
  cudaSupport ? config.cudaSupport,
}:
buildPythonPackage.override { stdenv = cudaPackages.backendStdenv; } (finalAttrs: {
  pname = "cuda-core";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cuda-python";
    tag = "cuda-core-v${finalAttrs.version}";
    hash = "sha256-SRy/hnOzzb4wUCLOre4k326RNhYI0650XzC8Dc9kf/M=";
  };

  nativeBuildInputs = [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    cudaPackages.cuda_nvrtc # nvrtc.h
    cudaPackages.cuda_profiler_api # cudaProfiler.h
  ];

  env = {
    CUDA_HOME = symlinkJoin {
      name = "cuda-redist";

      paths =
        with cudaPackages;
        [
          # Used to detect CUDA MAJOR VERSION
          (lib.getInclude cuda_cudart)
        ]
        ++ lib.optionals finalAttrs.doInstallCheck [
          # Compilation tests include <cuda/atomic> etc. (found via $CUDA_HOME/include)
          (lib.getInclude cccl)
        ];
    };
  };

  preBuild = ''
    export CUDA_PYTHON_PARALLEL_LEVEL=$NIX_BUILD_CORES
  '';

  # Tests require a GPU
  doCheck = false;

  nativeCheckInputs = [
    cffi
    cloudpickle
    psutil
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf cuda/core
  '';

  __structuredAttrs = true;

  build-system = [
    cuda-bindings
    cuda-pathfinder
    cython
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cuda-pathfinder
    numpy
  ];

  disabledTestPaths = [
    # AssertionError (tries to run an external python process that imports `cuda`)
    # ModuleNotFoundError: No module named 'cuda'
    "tests/test_rlcompleter_patch.py"
  ];

  disabledTests = [
    # Fail inside the sandbox:
    #   cuda.bindings.nvml.UnknownError: Unknown Error
    #   hwloc/linux: failed to find sysfs cpu topology directory, aborting linux discovery.
    "test_affinity"
    "test_device_cpu_affinity"
    "test_device_pci_bus_id"
    "test_device_pci_info"
    "test_to_cuda_device"
    "test_to_system_device"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cuda.core" ];
  sourceRoot = "${finalAttrs.src.name}/cuda_core";

  passthru.gpuCheck = cuda-core.overridePythonAttrs {
    doCheck = true;
    requiredSystemFeatures = [ "cuda" ];
  };

  meta = {
    description = "Pythonic interface to the CUDA runtime";
    homepage = "https://nvidia.github.io/cuda-python/cuda-core/latest";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
    ];

    broken = !cudaSupport;
    downloadPage = "https://github.com/NVIDIA/cuda-python/tree/main/cuda_core";
  };
})

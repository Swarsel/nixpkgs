{
  lib,
  fetchFromGitHub,
  # nativeBuildInputs
  autoAddDriverRunpath,
  autoPatchelfHook,
  buildPythonPackage,
  # build-system
  cmake,
  config,
  cudaPackages,
  # pytorch-only:
  einops,
  # jax-only
  flax,
  # dependencies
  importlib-metadata,
  jax,
  mpi,
  ninja,
  nvdlfw-inspect,
  onnx,
  onnxscript,
  packaging,
  pybind11,
  pydantic,
  python,
  replaceVars,
  setuptools,
  # pytorch-only:
  torch,
  # passthru
  transformer-engine,
  cudaCapabilities ?
    if withPytorch then torch.cudaCapabilities else cudaPackages.flags.cudaCapabilities,
  cudaSupport ? config.cudaSupport,
  withCusolvermp ? false,
  withJax ? true,
  withMpi ? false,
  withNvshmem ? false,
  withPytorch ? true,
}:

let
  inherit (lib)
    cmakeFeature
    concatStringsSep
    getInclude
    getLib
    optional
    optionalString
    optionals
    strings
    subtractLists
    ;
  inherit (cudaPackages) backendStdenv flags;

  frameworks =
    if (withJax || withPytorch) then
      concatStringsSep "," (optional withJax "jax" ++ optional withPytorch "pytorch")
    else
      "none";

  cudaCapabilities' = subtractLists [
    # Compilation will fail when providing those architectures:
    #   error: static assertion failed with "Compiled for the generic architecture, while utilizing
    #   family-specific features.
    #   Please compile for smXXXf architecture instead of smXXX architecture."
    # Providing 10.0 and 12.0 respectively is enough as the CMake file will automatically add the
    # correct compilation flags for supporting those architectures.
    "10.3"
    "12.1"
  ] cudaCapabilities;

in
buildPythonPackage.override { stdenv = backendStdenv; } (finalAttrs: {
  pname = "transformer-engine";
  version = "2.16.1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "TransformerEngine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jYQZwgBedpCALhXYw2qH7PwIoSz6ttUje78xjdF+CYc=";
    # Their CMakeLists.txt does not easily let us inject dependencies
    fetchSubmodules = true;
  };

  patches = optionals cudaSupport [
    (replaceVars ./cuda-libs-paths.patch {
      cudart_include_dir = "${getInclude cudaPackages.cuda_cudart}/include";
      libcudnn_so = "${getLib cudaPackages.cudnn}/lib/libcudnn.so";
      libcurand_so = "${getLib cudaPackages.libcurand}/lib/libcurand.so";
      libnvrtc_so = "${getLib cudaPackages.cuda_nvrtc}/lib/libnvrtc.so";
    })
  ];

  postPatch =
    # Patch build-system requirements:
    # - pybind11[global] doesn't exist in nixpkgs, just use regular pybind11
    # - pip is not required for building this package
    # - torch, jax and flax should not been unconditionally required, but depending on the selected
    #   'frameworks'
    ''
      substituteInPlace pyproject.toml \
        --replace-fail "pybind11[global]" "pybind11" \
        --replace-fail '"pip", "torch>=2.1", "jax>=0.5.0", "flax>=0.7.1"' ""
    ''
    # Harcode the path to the output store path that transformer_engine will use to import
    # - libtransformer_engine.so
    # - transformer_engine_jax.cpython-313-x86_64-linux-gnu.so
    # - transformer_engine_torch.cpython-313-x86_64-linux-gnu.so
    # This skips their impure find logic.
    + ''
      substituteInPlace transformer_engine/common/__init__.py \
        --replace-fail \
          'te_path = Path(importlib.util.find_spec("transformer_engine").origin).parent.parent' \
          'te_path = Path("${placeholder "out"}/${python.sitePackages}")'
    '';

  nativeBuildInputs = [
    autoAddDriverRunpath
    autoPatchelfHook
    cudaPackages.cuda_nvcc
  ]
  ++ optionals withMpi [
    # NOTE: mpi is in nativeBuildInputs because it contains compilers and is only discoverable by
    # CMake when a nativeBuildInput.
    mpi
  ];

  buildInputs = [
    cudaPackages.cuda_cudart # cuda_runtime.h
    cudaPackages.cuda_nvml_dev # nvml.h
    cudaPackages.cuda_nvrtc # nvrtc.h
    cudaPackages.cuda_nvtx # nvToolsExt.h
    cudaPackages.cuda_profiler_api # cuda_profiler_api.h
    cudaPackages.cudnn # cudnn.h
    cudaPackages.libcublas
    cudaPackages.libcurand # curand.h
    cudaPackages.libcusolver # cusolverDn.h
    cudaPackages.libcusparse # cusparse.h
    cudaPackages.nccl # nccl.h
    pybind11 # pybind11/pybind11.h
  ]
  ++ optionals withMpi [
    mpi # mpi.h
  ]
  ++ optionals withCusolvermp [
    cudaPackages.libcusolvermp
  ];

  # https://github.com/NVIDIA/TransformerEngine/blob/main/docs/envvars.rst
  env = {
    CUSOLVERMP_HOME = optionalString withCusolvermp (getLib cudaPackages.libcusolvermp).outPath;
    # NOTE: Make sure to use mpi from buildPackages to match the spliced version created through nativeBuildInputs.
    MPI_HOME = optionalString withMpi (getLib mpi).outPath;
    NVSHMEM_HOME = optionalString withNvshmem cudaPackages.libnvshmem.outPath;

    NVTE_CMAKE_EXTRA_ARGS = toString [
      (cmakeFeature "CUDNN_FRONTEND_INCLUDE_DIR" "${getInclude cudaPackages.cudnn-frontend}/include")
    ];

    NVTE_CUDA_ARCHS = strings.concatMapStringsSep ";" flags.dropDots cudaCapabilities';
    NVTE_ENABLE_NVSHMEM = if withNvshmem then 1 else 0;
    NVTE_FRAMEWORK = frameworks;
    # Do not include the git commit hash in the version string
    NVTE_NO_LOCAL_VERSION = 1;
    NVTE_RELEASE_BUILD = 0;
    NVTE_UB_WITH_MPI = if withMpi then 1 else 0;
    # Use the nixpkgs triton package
    NVTE_USE_PYTORCH_TRITON = 0;
    NVTE_WITH_CUSOLVERMP = if withCusolvermp then 1 else 0;
  };

  preBuild = ''
    export NVTE_BUILD_MAX_JOBS=$NIX_BUILD_CORES
  '';

  # Almost all tests require GPU access
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    pybind11
    setuptools
  ]
  ++ optionals withJax [
    flax
    jax
  ]
  ++ optionals withPytorch [
    # Required to build extensions
    torch
  ];

  dependencies = [
    importlib-metadata
    packaging
    pydantic
  ]
  ++ optionals withJax [
    flax
    jax
  ]
  ++ optionals withPytorch [
    einops
    nvdlfw-inspect
    onnx
    onnxscript
    torch
  ];

  dontUseCmakeConfigure = true;

  dontUsePythonImportsCheck =
    # When built with cusolvermp support `dlopen`ing libtransformer_engine.so `dlopen`s
    # libcuda.so.1 which is provided by the GPU driver at run time:
    # OSError: libcuda.so.1: cannot open shared object file: No such file or directory
    withCusolvermp

    # When built with nvshmem support `dlopen`ing libtransformer_engine.so `dlopen`s
    # libnvidia-ml.so.1 which is provided by the GPU driver at run time:
    # OSError: libnvidia-ml.so.1: cannot open shared object file: No such file or directory
    || withNvshmem;

  pyproject = true;

  pythonImportsCheck = [
    "transformer_engine"
  ]
  ++ optionals withJax [
    "transformer_engine_jax"
  ]
  ++ optionals withPytorch [
    "transformer_engine_torch"
  ];

  runtimeDependencies = optionals withNvshmem [
    # libnvshmem is already provided at build time by `$NVSHMEM_HOME`
    # We add it here so that it gets picked up by autoPatchelfHook
    (getLib cudaPackages.libnvshmem)
  ];

  passthru.tests = {
    withCusolvermp = transformer-engine.override { withCusolvermp = true; };
    withJax = transformer-engine.override { withJax = true; };
    withMpi = transformer-engine.override { withMpi = true; };
    withNvshmem = transformer-engine.override { withNvshmem = true; };
    withPytorch = transformer-engine.override { withPytorch = true; };
  };

  meta = {
    description = "Library for accelerating Transformer models on NVIDIA GPUs";
    homepage = "https://github.com/NVIDIA/TransformerEngine";
    changelog = "https://github.com/NVIDIA/TransformerEngine/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    broken = !cudaSupport;
  };
})

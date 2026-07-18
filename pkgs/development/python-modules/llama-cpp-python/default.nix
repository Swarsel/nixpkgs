{
  lib,
  stdenv,
  fetchFromGitHub,
  autoAddDriverRunpath,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  config,
  # dependencies
  diskcache,
  gcc13Stdenv,
  # passthru
  gitUpdater,
  huggingface-hub,
  jinja2,
  llama-cpp-python,
  ninja,
  numpy,
  # build-system
  pathspec,
  pyproject-metadata,
  pytestCheckHook,
  scikit-build-core,
  # tests
  scipy,
  typing-extensions,
  cudaPackages ? { },
  cudaSupport ? config.cudaSupport,
}:
let
  stdenvTarget = if cudaSupport then gcc13Stdenv else stdenv;
in
buildPythonPackage.override { stdenv = stdenvTarget; } rec {
  pname = "llama-cpp-python";
  version = "0.3.23";

  src = fetchFromGitHub {
    owner = "abetlen";
    repo = "llama-cpp-python";
    tag = "v${version}";
    hash = "sha256-LqSgohfTv02RNZGMjKG0Pq2vHuIX+446uI2Q3KRmnzI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ]
  ++ lib.optionals cudaSupport [
    autoAddDriverRunpath
  ];

  buildInputs = lib.optionals cudaSupport (
    with cudaPackages;
    [
      cuda_cudart # cuda_runtime.h
      cccl # <thrust/*>
      libcublas # cublas_v2.h
    ]
  );

  cmakeFlags = [
    # Set GGML_NATIVE=off. Otherwise, cmake attempts to build with
    # -march=native* which is either a no-op (if cc-wrapper is able to ignore
    # it), or an attempt to build a non-reproducible binary.
    #
    # This issue was spotted when cmake rules appended feature modifiers to
    # -mcpu, breaking linux build as follows:
    #
    # cc1: error: unknown value ‘native+nodotprod+noi8mm+nosve’ for ‘-mcpu’
    (lib.cmakeBool "GGML_NATIVE" false)
  ]
  ++ lib.optionals cudaSupport [
    (lib.cmakeBool "GGML_CUDA" true)
    (lib.cmakeFeature "CUDAToolkit_ROOT" "${lib.getDev cudaPackages.cuda_nvcc}")
    (lib.cmakeFeature "CMAKE_CUDA_COMPILER" "${lib.getExe cudaPackages.cuda_nvcc}")
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scipy
    huggingface-hub
  ];

  build-system = [
    pathspec
    pyproject-metadata
    scikit-build-core
  ];

  dependencies = [
    diskcache
    jinja2
    numpy
    typing-extensions
  ];

  disabledTests = [
    # tries to download model from huggingface-hub
    "test_real_model"
    "test_real_llama"
  ];

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;
  pyproject = true;

  pythonImportsCheck = lib.optionals (!cudaSupport) [
    # `libllama.so` is loaded at import time, and failing when cudaSupport is enabled as the cuda
    # driver is missing in the sandbox:
    # RuntimeError: Failed to load shared library '/nix/store/...-python3.13-llama-cpp-python-0.3.16/lib/python3.13/site-packages/llama_cpp/lib/libllama.so':
    # libcuda.so.1: cannot open shared object file: No such file or directory
    "llama_cpp"
  ];

  passthru = {
    tests = lib.optionalAttrs stdenvTarget.hostPlatform.isLinux {
      withCuda = llama-cpp-python.override {
        cudaSupport = true;
      };
    };

    updateScript = gitUpdater {
      allowedVersions = "^[.0-9]+$";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Python bindings for llama.cpp";
    homepage = "https://github.com/abetlen/llama-cpp-python";
    changelog = "https://github.com/abetlen/llama-cpp-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      booxter
      kirillrdy
    ];
  };
}

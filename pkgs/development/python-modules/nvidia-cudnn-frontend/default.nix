{
  lib,
  buildPythonPackage,
  # build-system
  cmake,
  # nativeBuildInputs
  cudaPackages,
  # buildInputs
  dlpack,
  # tests
  looseversion,
  ninja,
  # propagatedBuildInputs
  nlohmann_json,
  nvidia-cudnn-frontend,
  pybind11,
  pytestCheckHook,
  setuptools,
  torch,
}:
buildPythonPackage.override { stdenv = cudaPackages.backendStdenv; } (finalAttrs: {
  inherit (cudaPackages.cudnn-frontend)
    version
    src
    meta
    ;

  pname = "nvidia-cudnn-frontend";

  postPatch =
    cudaPackages.cudnn-frontend.postPatch
    + ''
      substituteInPlace pyproject.toml \
        --replace-fail '"ninja==1.11.1.1"' '"ninja"' \
        --replace-fail '"pybind11[global]>=2.13,<3"' '"pybind11"'

      sed -i '/cmake_args =/a\\f"-DCUDNN_FRONTEND_USE_SYSTEM_DLPACK=ON",' setup.py
    ''
    + ''
      substituteInPlace python/cudnn/__init__.py \
        --replace-fail \
          'os.path.join(sysconfig.get_path("purelib"), "nvidia/cudnn/lib/libcudnn.so.*[0-9]")' \
          '"${lib.getLib cudaPackages.cudnn}/lib/libcudnn.so"'
    '';

  nativeBuildInputs = [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvrtc # nvrtc.h
    cudaPackages.cudnn
    dlpack
  ];

  propagatedBuildInputs = [
    nlohmann_json
  ];

  # requires GPU
  doCheck = false;

  nativeCheckInputs = [
    looseversion
    pytestCheckHook
    torch
  ];

  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    pybind11
    setuptools
  ];

  dontUseCmakeConfigure = true;

  enabledTestPaths = [
    "test/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cudnn" ];

  passthru.gpuCheck = nvidia-cudnn-frontend.overridePythonAttrs {
    doCheck = true;
    requiredSystemFeatures = [ "cuda" ];
  };
})

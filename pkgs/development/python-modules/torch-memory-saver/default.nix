{
  lib,
  fetchFromGitHub,
  # nativeBuildInputs
  autoAddDriverRunpath,
  buildPythonPackage,
  cudaPackages,
  # tests
  nvidia-ml-py,
  pytestCheckHook,
  # build-system
  setuptools,
  symlinkJoin,
  # dependencies
  torch,
  torch-memory-saver,
}:
buildPythonPackage.override { inherit (torch) stdenv; } (finalAttrs: {
  pname = "torch-memory-saver";
  version = "0.0.9.post1";

  src = fetchFromGitHub {
    owner = "fzyzcjy";
    repo = "torch_memory_saver";
    # branch 0.0.9.post1
    rev = "0c88c358824bd304daeec34ac792a55e3fa2c1f2";
    hash = "sha256-xYkHhfCj3cOzAK5pmWCDfRw5FL8BzBkeUaDnqVlmSiY=";
  };

  # fix CUDA library_dirs
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail lib64 lib
  '';

  nativeBuildInputs = [
    autoAddDriverRunpath
  ];

  env = {
    CUDA_HOME = symlinkJoin {
      name = "cudatoolkit-joined";

      paths = [
        cudaPackages.cuda_nvcc # crt/host_defines.h
        cudaPackages.cuda_cudart # cuda_runtime_api.h
      ];
    };

    TMS_CUDA_MAJOR = cudaPackages.cudaMajorVersion;
  };

  # requires GPU
  doCheck = false;

  nativeCheckInputs = [
    # propagated from torch
    nvidia-ml-py
    pytestCheckHook
  ];

  preCheck = ''
    rm -r torch_memory_saver
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    nvidia-ml-py
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "torch_memory_saver" ];

  passthru.gpuCheck = torch-memory-saver.overridePythonAttrs {
    doCheck = true;
    requiredSystemFeatures = [ "cuda" ];
  };

  meta = {
    description = "Library that allows tensor memory to be temporarily released and resumed later";
    homepage = "https://github.com/fzyzcjy/torch_memory_saver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    # TODO: ROCm
    broken = !torch.cudaSupport;
  };
})

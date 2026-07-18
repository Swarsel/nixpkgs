{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  causal-conv1d,
  config,
  cudaPackages,
  einops,
  ninja,
  setuptools,
  torch,
  transformers,
  triton,
  which,
  cudaSupport ? config.cudaSupport,
}:

buildPythonPackage rec {
  pname = "mamba";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "state-spaces";
    repo = "mamba";
    tag = "v${version}";
    hash = "sha256-R702JjM3AGk7upN7GkNK8u1q4ekMK9fYQkpO6Re45Ng=";
  };

  nativeBuildInputs = [ which ];

  buildInputs = (
    lib.optionals cudaSupport (
      with cudaPackages;
      [
        cuda_cudart # cuda_runtime.h, -lcudart
        cccl
        libcusparse # cusparse.h
        libcusolver # cusolverDn.h
        cuda_nvcc
        libcublas
      ]
    )
  );

  env = {
    MAMBA_FORCE_BUILD = "TRUE";
  }
  // lib.optionalAttrs cudaSupport { CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}"; };

  build-system = [
    ninja
    setuptools
    torch
  ];

  dependencies = [
    causal-conv1d
    einops
    torch
    transformers
    triton
  ];

  pyproject = true;
  # pytest tests not enabled due to nvidia GPU dependency
  pythonImportsCheck = [ "mamba_ssm" ];

  meta = {
    description = "Linear-Time Sequence Modeling with Selective State Spaces";
    homepage = "https://github.com/state-spaces/mamba";
    license = lib.licenses.asl20;
    # The package requires CUDA or ROCm, the ROCm build hasn't
    # been completed or tested, so broken if not using cuda.
    broken = !cudaSupport;
  };
}

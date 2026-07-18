{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  config,
  cudaPackages,
  ninja,
  rocmPackages,
  setuptools,
  torch,
  which,
  cudaSupport ? config.cudaSupport,
  rocmGpuTargets ? rocmPackages.clr.localGpuTargets or rocmPackages.clr.gpuTargets,
  rocmSupport ? config.rocmSupport,
}:

buildPythonPackage rec {
  pname = "causal-conv1d";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "Dao-AILab";
    repo = "causal-conv1d";
    tag = "v${version}";
    hash = "sha256-hFaF/oMdScDpdq+zq8WppWe9GONWppEEx2pIcnaALiI=";
  };

  nativeBuildInputs = [ which ] ++ lib.optionals rocmSupport [ rocmPackages.clr ];

  buildInputs =
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
    ++ lib.optionals rocmSupport (
      with rocmPackages;
      [
        rocm-core
        rocm-device-libs
        rocm-runtime
        rocm-comgr
        hipblas
        rocblas
        hipcub
        rocprim
      ]
    );

  env = {
    CAUSAL_CONV1D_FORCE_BUILD = "TRUE";
  }
  // lib.optionalAttrs cudaSupport { CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}"; }
  // lib.optionalAttrs rocmSupport {
    CPLUS_INCLUDE_PATH = lib.makeSearchPath "include" [
      rocmPackages.hipcub
      rocmPackages.rocprim
    ];

    HIP_ARCHITECTURES = builtins.concatStringsSep "," rocmGpuTargets;
    ROCM_PATH = "${rocmPackages.clr}";
  };

  build-system = [
    ninja
    setuptools
    torch
  ];

  dependencies = [
    torch
  ];

  pyproject = true;
  # pytest tests not enabled due to GPU dependency
  pythonImportsCheck = [ "causal_conv1d" ];

  meta = {
    description = "Causal depthwise conv1d in CUDA with a PyTorch interface";
    homepage = "https://github.com/Dao-AILab/causal-conv1d";
    license = lib.licenses.bsd3;
    # The package requires either CUDA or ROCm.
    # It doesn't work without either, nor with both.
    broken = cudaSupport == rocmSupport;
  };
}

# Currently propagated by cuda_nvcc or cudatoolkit, rather than used directly
{
  lib,
  backendStdenv,
  makeSetupHook,
}:
makeSetupHook {
  name = "setup-cuda-hook";
  # Required in addition to ccRoot as otherwise bin/gcc is looked up
  # when building CMakeCUDACompilerId.cu
  substitutions.ccFullPath = "${backendStdenv.cc}/bin/${backendStdenv.cc.targetPrefix}c++";
  substitutions.setupCudaHook = placeholder "out";
  meta.license = lib.licenses.mit;
} ./setup-cuda-hook.sh

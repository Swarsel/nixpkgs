{
  lib,
  fetchFromGitHub,
  backendStdenv,
  # buildInputs
  boost,
  # nativeBuildInputs
  cmake,
  config,
  cuda_cudart,
  cuda_nvcc,
  cuda_nvml_dev,
  flags,
  # passthru
  nvbandwidth,
  cudaSupport ? config.cudaSupport,
}:
backendStdenv.mkDerivation (finalAttrs: {
  pname = "nvbandwidth";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "nvbandwidth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j1bKWXHIkjsE/M+w5rRF0UGjkj1gLA2yi+5hc1sWl/A=";
  };

  patches = [
    # Force a dynamic Boost build and link against the CUDA driver / NVML stubs via the CMake
    # imported targets exposed by `find_package(CUDAToolkit)`.
    ./use-cuda-imported-targets.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    cuda_nvcc
  ];

  buildInputs = [
    boost
    cuda_cudart # cuda_runtime.h, libcuda stub
    cuda_nvml_dev # libnvidia-ml
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" flags.cmakeCudaArchitecturesString)
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 nvbandwidth -t $out/bin

    runHook postInstall
  '';

  __structuredAttrs = true;

  passthru.gpuCheck = nvbandwidth.overrideAttrs (_: {
    doInstallCheck = true;

    postInstallCheck = ''
      $out/bin/${nvbandwidth.meta.mainProgram}
    '';

    requiredSystemFeatures = [ "cuda" ];
    # Failing (probably a sandbox limitation):
    #   hwloc/linux: failed to find sysfs cpu topology directory, aborting linux discovery.
    meta.broken = true;
  });

  meta = {
    description = "Tool for bandwidth measurements on NVIDIA GPUs";
    homepage = "https://github.com/NVIDIA/nvbandwidth";
    changelog = "https://github.com/NVIDIA/nvbandwidth/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
    mainProgram = "nvbandwidth";
    broken = !cudaSupport;
  };
})

{
  lib,
  backendStdenv,
  cccl,
  cmake,
  cudaNamePrefix,
  cuda_cudart,
  cuda_nvcc,
  flags,
  libcublas,
  saxpy,
}:
backendStdenv.mkDerivation (finalAttrs: {
  pname = "saxpy";
  version = "0-unstable-2023-07-11";
  src = ./src;
  strictDeps = true;

  nativeBuildInputs = [
    cmake
    cuda_nvcc
  ];

  buildInputs = [
    cccl
    cuda_cudart
    libcublas
  ];

  cmakeFlags = [
    (lib.cmakeBool "CMAKE_VERBOSE_MAKEFILE" true)
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" flags.cmakeCudaArchitecturesString)
  ];

  __structuredAttrs = true;
  name = "${cudaNamePrefix}-${finalAttrs.pname}-${finalAttrs.version}";

  passthru.gpuCheck = saxpy.overrideAttrs (_: {
    doInstallCheck = true;

    postInstallCheck = ''
      $out/bin/${saxpy.meta.mainProgram or (lib.getName saxpy)}
    '';

    requiredSystemFeatures = [ "cuda" ];
  });

  meta = {
    description = "Simple (Single-precision AX Plus Y) FindCUDAToolkit.cmake example for testing cross-compilation";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "saxpy";
    teams = [ lib.teams.cuda ];
  };
})

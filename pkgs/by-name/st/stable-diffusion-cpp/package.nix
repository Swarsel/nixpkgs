{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk,
  autoAddDriverRunpath,
  clblast,
  cmake,
  darwin,
  ninja,
  pkg-config,
  python3,
  shaderc,
  spirv-tools,
  vulkan-headers,
  vulkan-loader,
  config ? { },
  cudaPackages ? { },
  cudaSupport ? (config.cudaSupport or false),
  metalSupport ? (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64),
  openclSupport ? false,
  rocmGpuTargets ? (rocmPackages.clr.localGpuTargets or rocmPackages.clr.gpuTargets or [ ]),
  rocmPackages ? { },
  rocmSupport ? (config.rocmSupport or false),
  vulkanSupport ? false,
}:

let
  inherit (lib)
    cmakeBool
    cmakeFeature
    optionals
    optionalString
    ;

  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "stable-diffusion-cpp";
  version = "master-741-484baa4";

  src = fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "master-741-484baa4";
    hash = "sha256-7NM3wGgqdFRCYUwIzoD7bA5yvV7n07gncheQFU7iNIs=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ]
  ++ optionals cudaSupport [
    (cudaPackages.cuda_nvcc)
    autoAddDriverRunpath
  ];

  buildInputs =
    (optionals cudaSupport (
      with cudaPackages;
      [
        cccl
        cuda_cudart
        libcublas
      ]
    ))
    ++ (optionals rocmSupport (
      with rocmPackages;
      [
        clr
        hipblas
        rocblas
      ]
    ))
    ++ (optionals vulkanSupport [
      shaderc
      vulkan-headers
      vulkan-loader
      spirv-tools
    ])
    ++ (optionals openclSupport [
      clblast
    ])
    ++ (optionals metalSupport [
      apple-sdk
    ]);

  cmakeFlags = [
    (cmakeBool "SD_BUILD_EXAMPLES" true)
    (cmakeBool "SD_BUILD_SHARED_LIBS" true)
    (cmakeBool "SD_USE_SYSTEM_GGML" false)
    (cmakeBool "SD_CUDA" cudaSupport)
    (cmakeBool "SD_HIPBLAS" rocmSupport)
    (cmakeBool "SD_VULKAN" vulkanSupport)
    (cmakeBool "SD_OPENCL" openclSupport)
    (cmakeBool "SD_METAL" metalSupport)
    (cmakeBool "SD_FAST_SOFTMAX" false)
  ]
  ++ optionals cudaSupport [
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ]
  ++ optionals rocmSupport [
    (cmakeFeature "CMAKE_HIP_ARCHITECTURES" (builtins.concatStringsSep ";" rocmGpuTargets))
  ];

  meta = {
    description = "Stable Diffusion inference in pure C/C++";
    homepage = "https://github.com/leejet/stable-diffusion.cpp";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      adriangl
    ];

    platforms = lib.platforms.unix;
    badPlatforms = lib.optionals (cudaSupport || openclSupport) lib.platforms.darwin;
    mainProgram = "sd";
    broken = metalSupport && !stdenv.hostPlatform.isDarwin;
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  fmt,
  glslang,
  ninja,
  spdlog,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kompute";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "KomputeProject";
    repo = "kompute";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cf9Ef85R+VKao286+WHLgBWUqgwvuRocgeCzVJOGbdc=";
  };

  patches = [
    # FIXME: remove next update
    (fetchpatch {
      name = "vulkan-14-support.patch";
      sha256 = "sha256-JuoTQ+VjIdyF+I1IcT1ofbBjRS0Ibm2w6F2jrRJlx40=";
      url = "https://github.com/KomputeProject/kompute/commit/299b11fb4b8a7607c5d2c27e2735f26b06ae8e29.patch";
    })

    # Fix the build with fmt ≥ 11.
    (fetchpatch {
      hash = "sha256-sZf1lazaGaiRzry0Y+KE6z3FKm79gVKoSFyW0GN3TMM=";
      url = "https://github.com/KomputeProject/kompute/commit/e7985da9950bf75f00799f73b0e1d4ea7c24f0b2.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    fmt
    spdlog
  ];

  propagatedBuildInputs = [
    glslang
    vulkan-headers
    vulkan-loader
  ];

  cmakeFlags = [
    "-DKOMPUTE_OPT_USE_SPDLOG=ON"
    # Doesn’t work without the vendored `spdlog`, and is redundant.
    "-DKOMPUTE_OPT_LOG_LEVEL_DISABLED=ON"
    "-DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF"
    "-DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF"
    "-DKOMPUTE_OPT_USE_BUILT_IN_GOOGLE_TEST=OFF"
    "-DKOMPUTE_OPT_USE_BUILT_IN_PYBIND11=OFF"
    "-DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF"
    "-DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON"
    "-DKOMPUTE_OPT_INSTALL=1"
  ];

  meta = {
    description = "General purpose GPU compute framework built on Vulkan";

    longDescription = ''
      General purpose GPU compute framework built on Vulkan to
      support 1000s of cross vendor graphics cards (AMD,
      Qualcomm, NVIDIA & friends). Blazing fast, mobile-enabled,
      asynchronous and optimized for advanced GPU data
      processing usecases. Backed by the Linux Foundation"
    '';

    homepage = "https://kompute.cc/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})

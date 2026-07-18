{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  bluez,
  cjson,
  cmake,
  config,
  cudaPackages,
  dbus,
  doxygen,
  eigen,
  elfutils,
  fetchpatch,
  glslang,
  gst_all_1,
  hidapi,
  libGL,
  libbsd,
  libdrm,
  libffi,
  libjpeg,
  librealsense,
  libsurvive,
  libunwind,
  libusb1,
  libuv,
  libuvc,
  libv4l,
  libxau,
  libxcb,
  libxdmcp,
  libxext,
  libxrandr,
  nix-update-script,
  nixosTests,
  onnxruntime,
  opencv4,
  openvr,
  orc,
  pcre2,
  pkg-config,
  python3,
  shaderc,
  tracy,
  udev,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-protocols,
  wayland-scanner,
  writeText,
  zlib,
  zstd,
  enableCuda ? config.cudaSupport,
  # Set as 'false' to build monado without service support, i.e. allow VR
  # applications linking against libopenxr_monado.so to use OpenXR standalone
  # instead of via the monado-service program. For more information see:
  # https://gitlab.freedesktop.org/monado/monado/-/blob/master/doc/targets.md#xrt_feature_service-disabled
  serviceSupport ? true,
  tracingSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "monado";
  version = "25.1.0";

  src = fetchFromGitLab {
    owner = "monado";
    repo = "monado";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hUSm76PV+FhvzhiYMUbGcNDQMK1TZCPYh1PNADJmdSU=";
    domain = "gitlab.freedesktop.org";
  };

  patches = [
    # Resolves issues with wayvr
    # See https://github.com/NixOS/nixpkgs/pull/489154#issuecomment-4018732528
    (fetchpatch {
      hash = "sha256-6lD4j7CMQk52btfxD8hOm0GWZaOxSgc1jel9hyXqktA=";
      name = "monado-cylinder-aspectRatio.patch";
      url = "https://gitlab.freedesktop.org/monado/monado/-/commit/69834fe93b84640170f8efa54b4700e5e0dc03c1.diff";
    })
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    glslang
    pkg-config
    python3
  ];

  # known disabled drivers/features:
  #  - DRIVER_DEPTHAI - Needs depthai-core https://github.com/luxonis/depthai-core (See https://github.com/NixOS/nixpkgs/issues/292618)
  #  - DRIVER_ILLIXR - needs ILLIXR headers https://github.com/ILLIXR/ILLIXR (See https://github.com/NixOS/nixpkgs/issues/292661)
  #  - DRIVER_ULV2 - Needs proprietary Leapmotion SDK https://api.leapmotion.com/documentation/v2/unity/devguide/Leap_SDK_Overview.html (See https://github.com/NixOS/nixpkgs/issues/292624)
  #  - DRIVER_ULV5 - Needs proprietary Leapmotion SDK https://api.leapmotion.com/documentation/v2/unity/devguide/Leap_SDK_Overview.html (See https://github.com/NixOS/nixpkgs/issues/292624)

  buildInputs = [
    bluez
    cjson
    dbus
    eigen
    elfutils
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    hidapi
    libbsd
    libdrm
    libffi
    libGL
    libjpeg
    librealsense
    libsurvive
    libunwind
    libusb1
    libuv
    libuvc
    libv4l
    libxau
    libxcb
    libxdmcp
    libxext
    libxrandr
    onnxruntime
    opencv4
    openvr
    orc
    pcre2
    SDL2
    shaderc
    udev
    vulkan-headers
    vulkan-loader
    wayland
    wayland-protocols
    wayland-scanner
    zlib
    zstd
  ]
  ++ lib.optionals tracingSupport [
    tracy
  ]
  ++ lib.optionals enableCuda [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
  ];

  cmakeFlags = [
    (lib.cmakeBool "XRT_FEATURE_SERVICE" serviceSupport)
    (lib.cmakeBool "XRT_HAVE_TRACY" tracingSupport)
    (lib.cmakeBool "XRT_FEATURE_TRACING" tracingSupport)
    (lib.cmakeBool "XRT_OPENXR_INSTALL_ABSOLUTE_RUNTIME_PATH" true)
  ];

  # Help openxr-loader find this runtime
  setupHook = writeText "setup-hook" ''
    export XDG_CONFIG_DIRS=@out@/etc/xdg''${XDG_CONFIG_DIRS:+:''${XDG_CONFIG_DIRS}}
  '';

  passthru = {
    tests.basic-service = nixosTests.monado;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open source XR runtime";
    homepage = "https://monado.freedesktop.org/";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.linux;
    mainProgram = "monado-cli";
  };
})

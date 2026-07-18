{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  cmake,
  cudaPackages,
  gtest,
  libdrm,
  ncurses,
  testers,
  udev,
  amd ? false,
  apple ? false,
  ascend ? false,
  enflame ? false,
  intel ? false,
  metax ? false,
  msm ? false,
  nvidia ? false,
  panfrost ? false,
  panthor ? false,
  rockchip ? false,
  tpu ? false,
  v3d ? false,
}:

let
  drm-postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${
        lib.makeLibraryPath [
          libdrm
          ncurses
          udev
        ]
      }" \
      $out/bin/nvtop
  '';
  needDrm = (amd || msm || panfrost || panthor || intel);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nvtop";
  version = "3.3.2";

  # between generation of multiple update PRs for each package flavor and manual updates I choose manual updates
  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "Syllo";
    repo = "nvtop";
    rev = finalAttrs.version;
    hash = "sha256-w3g/9VbZz1qrEMaBBHEf9Y93z0vo8LbWnENL2wEEaSw=";
  };

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals finalAttrs.doCheck [
    gtest
  ]
  ++ lib.optional nvidia addDriverRunpath;

  buildInputs = [
    ncurses
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux udev
  ++ lib.optional nvidia cudaPackages.cuda_nvml_dev
  ++ lib.optional needDrm libdrm;

  cmakeFlags = with lib.strings; [
    (cmakeBool "BUILD_TESTING" true)
    (cmakeBool "USE_LIBUDEV_OVER_LIBSYSTEMD" true)
    (cmakeBool "AMDGPU_SUPPORT" amd)
    (cmakeBool "NVIDIA_SUPPORT" nvidia)
    (cmakeBool "INTEL_SUPPORT" intel)
    (cmakeBool "APPLE_SUPPORT" apple)
    (cmakeBool "MSM_SUPPORT" msm)
    (cmakeBool "PANFROST_SUPPORT" panfrost)
    (cmakeBool "PANTHOR_SUPPORT" panthor)
    (cmakeBool "ASCEND_SUPPORT" ascend)
    (cmakeBool "V3D_SUPPORT" v3d)
    (cmakeBool "TPU_SUPPORT" tpu) # requires libtpuinfo which is not packaged yet
    (cmakeBool "ROCKCHIP_SUPPORT" rockchip)
    (cmakeBool "METAX_SUPPORT" metax)
    (cmakeBool "ENFLAME_SUPPORT" enflame)
  ];

  # this helps cmake to find <drm.h>
  env.NIX_CFLAGS_COMPILE = lib.optionalString needDrm "-isystem ${lib.getDev libdrm}/include/libdrm";
  # https://github.com/Syllo/nvtop/commit/33ec008e26a00227a666ccb11321e9971a50daf8
  doCheck = !stdenv.hostPlatform.isDarwin;

  # ordering of fixups is important
  postFixup =
    (lib.optionalString needDrm drm-postFixup)
    + (lib.optionalString nvidia "addDriverRunpath $out/bin/nvtop");

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "nvtop --version";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "htop-like task monitor for AMD, Adreno, Intel and NVIDIA GPUs";

    longDescription = ''
      Nvtop stands for Neat Videocard TOP, a (h)top like task monitor for AMD, Adreno, Intel and NVIDIA GPUs.
      It can handle multiple GPUs and print information about them in a htop familiar way.
    '';

    homepage = "https://github.com/Syllo/nvtop";
    changelog = "https://github.com/Syllo/nvtop/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      gbtb
      anthonyroussel
      moni
    ];

    platforms = if apple then lib.platforms.darwin else lib.platforms.linux;
    mainProgram = "nvtop";
  };
})

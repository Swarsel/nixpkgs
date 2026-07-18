{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  kmod,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "v4l2loopback";
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "umlaeute";
    repo = "v4l2loopback";
    tag = "v${version}";
    hash = "sha256-KXJgsEJJTr4TG4Ww5HlF42v2F1J+AsHwrllUP1n/7g8=";
  };

  outputs = [
    "out"
    "bin"
  ];

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "v4l2loopback.ko"
  ];

  preBuild = ''
    substituteInPlace Makefile --replace-fail "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    sed -i '/depmod/d' Makefile
  '';

  # Don't use makeFlags for this
  postBuild = ''
    make utils
  '';

  postInstall = ''
    make install-utils PREFIX=$bin
  '';

  hardeningDisable = [
    "format"
    "pic"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Kernel module to create V4L2 loopback devices";
    homepage = "https://github.com/umlaeute/v4l2loopback";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      moni
      bot-wxt1221
    ];

    platforms = lib.platforms.linux;
    mainProgram = "v4l2loopback-ctl";
    outputsToInstall = [ "out" ];
  };
}

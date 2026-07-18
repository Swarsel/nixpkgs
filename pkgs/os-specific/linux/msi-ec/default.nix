{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  kernelModuleMakeFlags,
  linuxPackages,
  kernel ? linuxPackages.kernel,
}:
stdenv.mkDerivation {
  pname = "msi-ec-kmods";
  version = "0-unstable-2025-09-17";

  src = fetchFromGitHub {
    owner = "BeardOverflow";
    repo = "msi-ec";
    rev = "ed92e2eb0005ab815f5492c8cb02495289263738";
    hash = "sha256-9jynXUvSZT2smyciK8GqojC/4MtxtqfQvJcf5RgPXKY=";
  };

  patches = [
    ./patches/makefile.patch
    ./patches/kernel-string-choices.patch
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ git ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  dontMakeSourcesWritable = false;
  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Kernel modules for MSI Embedded controller";
    homepage = "https://github.com/BeardOverflow/msi-ec";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.m1dugh ];
    platforms = lib.platforms.linux;
    broken = kernel.kernelOlder "6.5";
  };
}

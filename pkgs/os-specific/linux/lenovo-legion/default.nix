{
  lib,
  stdenv,
  bash,
  kernel,
  kernelModuleMakeFlags,
  lenovo-legion,
}:

stdenv.mkDerivation {
  inherit (lenovo-legion) version src;
  pname = "lenovo-legion-module";
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "SHELL=bash"
    "KERNELVERSION=${kernel.modDirVersion}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALLDIR=${placeholder "out"}/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86"
    "MODDESTDIR=${placeholder "out"}/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86"
    "DKMSDIR=${placeholder "out"}/lib/modules/${kernel.modDirVersion}/misc"
  ];

  preConfigure = ''
    sed -i -e '/depmod/d' ./Makefile
  '';

  hardeningDisable = [ "pic" ];
  sourceRoot = "${lenovo-legion.src.name}/kernel_module";

  meta = {
    description = "Linux kernel module for controlling fan and power in Lenovo Legion laptops";
    homepage = "https://github.com/johnfanv2/LenovoLegionLinux";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.ulrikstrid ];
    platforms = [ "x86_64-linux" ];
    broken = kernel.kernelOlder "5.15";
  };
}

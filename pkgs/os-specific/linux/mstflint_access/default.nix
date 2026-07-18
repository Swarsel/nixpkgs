{
  lib,
  stdenv,
  fetchurl,
  kernel,
  kernelModuleMakeFlags,
  kmod,
  mstflint,
}:

stdenv.mkDerivation rec {
  inherit (mstflint) version src;
  pname = "mstflint_access";
  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KVER=${kernel.modDirVersion}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  enableParallelBuilding = true;

  installFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "M=$(PWD)"
  ]
  ++ makeFlags;

  installTargets = [ "modules_install" ];
  sourceRoot = "source/kernel";

  meta = {
    description = "Kernel module for Nvidia NIC firmware update";
    homepage = "https://github.com/Mellanox/mstflint";
    license = [ lib.licenses.gpl2Only ];
    maintainers = with lib.maintainers; [ thillux ];
    platforms = lib.platforms.linux;
  };
}

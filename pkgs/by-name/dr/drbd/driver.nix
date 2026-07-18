{
  lib,
  stdenv,
  fetchurl,
  coccinelle,
  flex,
  kernel,
  kernelModuleMakeFlags,
  nixosTests,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drbd";
  version = "9.2.16";

  src = fetchurl {
    url = "https://pkg.linbit.com//downloads/drbd/9/drbd-${finalAttrs.version}.tar.gz";
    hash = "sha256-2ff9XtSlUnJG5y6qrRYGTgQiZdEnzywKaKR96ItF8Zw=";
  };

  postPatch = ''
    patchShebangs .
    substituteInPlace Makefile --replace 'SHELL=/bin/bash' 'SHELL=${builtins.getEnv "SHELL"}'
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [
    flex
    coccinelle
    python3
  ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KVER=${kernel.version}"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "M=$(sourceRoot)"
    "SPAAS=false"
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  passthru.tests.drbd-driver = nixosTests.drbd-driver;

  meta = {
    description = "LINBIT DRBD kernel module";

    longDescription = ''
      DRBD is a software-based, shared-nothing, replicated storage solution
      mirroring the content of block devices (hard disks, partitions, logical volumes, and so on) between hosts.
    '';

    homepage = "https://github.com/LINBIT/drbd";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ birkb ];
    platforms = lib.platforms.linux;
    broken = kernel.kernelOlder "5.11";
  };
})

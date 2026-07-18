{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation rec {
  pname = "ch9344";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "WCHSoftGroup";
    repo = "ch9344ser_linux";
    rev = "e0a38c4f4f9d4c1f5e2e3a352b7b1010b33aa322";
    hash = "sha256-ldYoGmG9DAjASl3xL8djeZ8jRHlcBQdAt0KYAr53epI=";
  };

  patches = [
    ./fix-linux-6-12-build.patch
    ./fix-linux-6-15-build.patch
    ./fix-linux-6-16-build.patch
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  preBuild = ''
    substituteInPlace Makefile --replace "KERNELDIR :=" "KERNELDIR ?="
  '';

  installPhase = ''
    runHook preInstall
    install -D ch9344.ko $out/lib/modules/${kernel.modDirVersion}/usb/serial/ch9344.ko
    runHook postInstall
  '';

  hardeningDisable = [ "pic" ];
  sourceRoot = "${src.name}/driver";

  meta = {
    description = "WCH CH9344/CH348 UART driver";

    longDescription = ''
      A kernel module for WinChipHead CH9344/CH348 USB To Multi Serial Ports controller.
    '';

    homepage = "https://www.wch-ic.com/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ RadxaYuntian ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/WCHSoftGroup/ch9344ser_linux";
  };
}

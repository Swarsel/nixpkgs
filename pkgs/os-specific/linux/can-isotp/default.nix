{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "can-isotp";
  version = "20200910";

  src = fetchFromGitHub {
    owner = "hartkopp";
    repo = "can-isotp";
    rev = "21a3a59e2bfad246782896841e7af042382fcae7";
    sha256 = "1laax93czalclg7cy9iq1r7hfh9jigh7igj06y9lski75ap2vhfq";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  buildFlags = [ "modules" ];
  hardeningDisable = [ "pic" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Kernel module for ISO-TP (ISO 15765-2)";
    homepage = "https://github.com/hartkopp/can-isotp";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.evck ];
    platforms = lib.platforms.linux;
    broken = kernel.kernelAtLeast "5.16";
  };
}

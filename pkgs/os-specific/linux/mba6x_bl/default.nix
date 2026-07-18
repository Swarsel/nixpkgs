{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "mba6x_bl";
  version = "unstable-2017-12-30";

  src = fetchFromGitHub {
    owner = "patjak";
    repo = "mba6x_bl";
    rev = "639719f516b664051929c2c0c1140ea4bf30ce81";
    sha256 = "sha256-QwxBpNa5FitKO+2ne54IIcRgwVYeNSQWI4f2hPPB8ls=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];

  meta = {
    description = "MacBook Air 6,1 and 6,2 (mid 2013) backlight driver";
    homepage = "https://github.com/patjak/mba6x_bl";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.simonvandel ];
    platforms = lib.platforms.linux;
    broken = lib.versionAtLeast kernel.version "6.11";
  };
}

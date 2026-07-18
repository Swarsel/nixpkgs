{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "rtl88x2bu";
  version = "${kernel.version}-unstable-2025-12-04";

  src = fetchFromGitHub {
    owner = "RinCat";
    repo = "RTL88x2BU-Linux-Driver";
    rev = "825556e195ecde9ce8f5f4cbad9953f398c8598e";
    hash = "sha256-MkvVCWyMOCBzCRufbKMuaaFOPhokZdFnXHYnrAwBe6M=";
  };

  nativeBuildInputs = [ bc ] ++ kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags;

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace /sbin/depmod \# \
      --replace '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  meta = {
    description = "Realtek rtl88x2bu driver";
    homepage = "https://github.com/RinCat/RTL88x2BU-Linux-Driver";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      otavio
      claymorwan
    ];

    platforms = lib.platforms.linux;
    broken = kernel.kernelOlder "5.11";
  };
}

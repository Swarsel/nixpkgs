{
  lib,
  stdenv,
  fetchzip,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hpuefi-mod";
  version = "3.05";

  src = fetchzip {
    url = "https://ftp.hp.com/pub/softpaq/sp150501-151000/sp150953.tgz";
    hash = "sha256-ofzqu5Y2g+QU0myJ4SF39ZJGXH1zXzX1Ys2FhXVTQKE=";
    stripRoot = false;
  };

  postPatch = ''
    substituteInPlace hpuefi.h \
      --replace-fail '&((p)->flags)' '(unsigned long *)&((p)->flags)'
  '';

  strictDeps = true;
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KVERS=${kernel.modDirVersion}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "DESTDIR=$(out)"
  ];

  prePatch = ''
    substituteInPlace "Makefile" \
      --replace-fail depmod \#
  '';

  unpackPhase = ''
    tar -xzf "$src/non-rpms/hpuefi-mod-${finalAttrs.version}.tgz"
    cd hpuefi-mod-${finalAttrs.version}
  '';

  meta = {
    description = "Kernel module for managing BIOS settings and updating BIOS firmware on supported HP computers";
    homepage = "https://ftp.hp.com/pub/caps-softpaq/cmit/linuxtools/HP_LinuxTools.html";
    license = lib.licenses.gpl2Only; # See "License" section in ./non-rpms/hpuefi-mod-*.tgz/README
    maintainers = with lib.maintainers; [ tomodachi94 ];
    platforms = [ "x86_64-linux" ];
  };
})

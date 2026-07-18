{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "virtio_vmmci";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "voutilad";
    repo = "virtio_vmmci";
    rev = finalAttrs.version;
    hash = "sha256-h8yu4+vTgpAD+sKa1KnVD+qubiIlkYtG2nmQnXOi/sk=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "DEPMOD=echo"
    "INSTALL_MOD_PATH=$(out)"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  enableParallelBuilding = true;

  extraConfig = ''
    CONFIG_RTC_HCTOSYS yes
  '';

  hardeningDisable = [
    "pic"
    "format"
  ];

  name = "${finalAttrs.pname}-${finalAttrs.version}-${kernel.version}";

  meta = {
    description = "OpenBSD VMM Control Interface (vmmci) for Linux";
    homepage = "https://github.com/voutilad/virtio_vmmci";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ qbit ];
    platforms = lib.platforms.linux;
  };
})

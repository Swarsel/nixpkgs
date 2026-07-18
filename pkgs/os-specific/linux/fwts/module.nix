{
  lib,
  stdenv,
  fwts,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (fwts) src;
  pname = "fwts-efi-runtime";
  version = "${fwts.version}-${kernel.version}";

  postPatch = ''
    substituteInPlace Makefile --replace \
      '/lib/modules/$(KVER)/build' \
      '${kernel.dev}/lib/modules/${kernel.modDirVersion}/build'
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  hardeningDisable = [ "pic" ];
  sourceRoot = "${fwts.sourceRoot}/efi_runtime";

  meta = {
    inherit (fwts.meta) homepage license;
    description = fwts.meta.description + "(efi-runtime kernel module)";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})

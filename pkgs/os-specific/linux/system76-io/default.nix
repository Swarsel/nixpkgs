{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
let
  hash = "sha256-VE6sCehjXlRuOVcK4EN2H+FhaVaBi/jrAYx4TZjbreA=";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "system76-io-module";
  version = "1.0.4";

  src = fetchFromGitHub {
    inherit hash;
    owner = "pop-os";
    repo = "system76-io-dkms";
    rev = finalAttrs.version;
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D system76-io.ko $out/lib/modules/${kernel.modDirVersion}/misc/system76-io.ko
    install -D system76-thelio-io.ko $out/lib/modules/${kernel.modDirVersion}/misc/system76-thelio-io.ko
  '';

  hardeningDisable = [ "pic" ];
  name = "${finalAttrs.pname}-${finalAttrs.version}-${kernel.version}";
  passthru.moduleName = "system76_io";

  meta = {
    description = "DKMS module for controlling System76 Io board";
    homepage = "https://github.com/pop-os/system76-io-dkms";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ahoneybun ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
    ];

    broken = lib.versionOlder kernel.version "5.10";
  };
})

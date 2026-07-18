{
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  libajantv2,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (libajantv2) src;
  pname = "ajantv2-module";
  version = libajantv2.version;

  patches = [
    ./fix-linux-6.15.patch
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags;

  buildFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  preBuild = ''
    chmod -R +w ../../
  '';

  installPhase = ''
    install -D ajantv2.ko $out/lib/modules/${kernel.modDirVersion}/misc/ajantv2.ko
    install -D ajardma.ko $out/lib/modules/${kernel.modDirVersion}/misc/ajardma.ko
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];
  name = "${finalAttrs.version}-${finalAttrs.version}-${kernel.version}";
  patchFlags = "-p3";
  sourceRoot = "${libajantv2.src.name}/driver/linux";

  meta = {
    inherit (libajantv2.meta) license homepage maintainers;
    description = "AJA video driver";

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})

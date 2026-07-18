{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
let
  hash = "sha256-9/t+Mvfnq0KkPbe1mnrVy4mzNaK7vAgLuhUnOeEvBfI=";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "system76-module";
  version = "1.0.17";

  src = fetchFromGitHub {
    inherit hash;
    owner = "pop-os";
    repo = "system76-dkms";
    rev = finalAttrs.version;
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D system76.ko $out/lib/modules/${kernel.modDirVersion}/misc/system76.ko
    mkdir -p $out/lib/udev/hwdb.d
    mv lib/udev/hwdb.d/* $out/lib/udev/hwdb.d
  '';

  hardeningDisable = [ "pic" ];
  name = "${finalAttrs.pname}-${finalAttrs.version}-${kernel.version}";
  passthru.moduleName = "system76";

  meta = {
    description = "System76 DKMS driver";

    longDescription = ''
      The System76 DKMS driver. On newer System76 laptops, this driver controls
      some of the hotkeys and allows for custom fan control.
    '';

    homepage = "https://github.com/pop-os/system76-dkms";
    license = [ lib.licenses.gpl2Plus ];
    maintainers = with lib.maintainers; [ ahoneybun ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "system76-acpi-module";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "system76-acpi-dkms";
    tag = finalAttrs.version;
    hash = "sha256-EJGKimf+mDSCG6+I7DZuo5GfPVqGPPkcADDtxoqV/8Q=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  # GCC 14 makes this an error by default, remove when fixed upstream
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  installPhase = ''
    runHook preInstall

    install -D system76_acpi.ko $out/lib/modules/${kernel.modDirVersion}/misc/system76_acpi.ko
    mkdir -p $out/lib/udev/hwdb.d
    mv lib/udev/hwdb.d/* $out/lib/udev/hwdb.d

    runHook postInstall
  '';

  hardeningDisable = [ "pic" ];
  name = "${finalAttrs.pname}-${finalAttrs.version}-${kernel.version}";
  passthru.moduleName = "system76_acpi";

  meta = {
    description = "System76 ACPI Driver (DKMS)";

    longDescription = ''
      This provides the system76_acpi in-tree driver for systems missing it.
    '';

    homepage = "https://github.com/pop-os/system76-acpi-dkms";
    license = [ lib.licenses.gpl2Only ];
    maintainers = with lib.maintainers; [ ahoneybun ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    broken = kernel.kernelOlder "5.2";
  };
})

bcachefs-tools:
{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  rustPlatform,
}:

stdenv.mkDerivation {
  pname = "bcachefs";
  version = "${kernel.version}-${bcachefs-tools.version}";
  src = bcachefs-tools.dkms;

  postPatch = ''
    substituteInPlace src/fs/bcachefs/Makefile \
      --replace-fail '$(objtree)/vmlinux' '${kernel.dev}/vmlinux'
  '';

  strictDeps = true;
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "RUST_LIB_SRC=${rustPlatform.rustLibSrc}"
  ];

  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules_install "''${makeFlags[@]}" "''${installFlags[@]}"
    runHook postInstall
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  passthru = {
    inherit (bcachefs-tools.passthru) tests;
  };

  meta = {
    inherit (bcachefs-tools.meta)
      homepage
      downloadPage
      license
      maintainers
      platforms
      ;

    description = "out-of-tree bcachefs kernel module";
    broken = !(lib.versionAtLeast kernel.version "6.16" && lib.versionOlder kernel.version "7.3");
  };
}

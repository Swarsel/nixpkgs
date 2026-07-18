{
  lib,
  stdenv,
  edk2,
  llvmPackages,
  nasm,
  pkgsBuildHost,
  python3,
  util-linux,
}:
edk2.mkDerivation "ShellPkg/ShellPkg.dsc" (finalAttrs: {
  inherit (edk2) version;
  pname = "edk2-uefi-shell";
  strictDeps = true;

  nativeBuildInputs = [
    util-linux
    nasm
    python3
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.bintools
    llvmPackages.llvm
  ];

  env = {
    # Set explicitly to use Python 3 from nixpkgs. Otherwise, the build system will detect and try to
    # use `/usr/bin/python3` on Darwin when sandboxing is disabled.
    PYTHON_COMMAND = "${lib.getBin pkgsBuildHost.python3}/bin/python3";
  }
  // lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = toString [
      "-fno-pic"
      "-Qunused-arguments"
    ];
  };

  # GUID hardcoded to match ShellPkg.dsc
  installPhase = ''
    runHook preInstall
    install -D -m0644 Build/Shell/RELEASE*/*/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi $out/shell.efi
    runHook postInstall
  '';

  # We only have a .efi file in $out which shouldn't be patched or stripped
  dontPatchELF = true;
  dontStrip = true;
  passthru.efi = "${finalAttrs.finalPackage}/shell.efi";

  meta = {
    inherit (edk2.meta) license platforms;
    description = "UEFI Shell from Tianocore EFI development kit";
    homepage = "https://github.com/tianocore/tianocore.github.io/wiki/ShellPkg";

    maintainers = with lib.maintainers; [
      LunNova
      mjoerg
    ];

    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
})

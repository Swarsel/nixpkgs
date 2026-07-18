{
  lib,
  stdenv,
  fetchFromGitLab,
  acpica-tools,
  edk2,
  llvmPackages,
  nasm,
  nixosTests,
  util-linux,
  debug ? false,
  fdSize2MB ? false,
  fdSize4MB ? secureBoot,
  fwPrefix ?
    {
      aarch64 = "CLOUDHV_EFI";
      x86_64 = "CLOUDHV";
    }
    .${stdenv.hostPlatform.parsed.cpu.name}
      or (throw "Unsupported OVMF `fwPrefix` on ${stdenv.hostPlatform.parsed.cpu.name}"),
  httpSupport ? false,
  projectDscPath ?
    {
      aarch64 = "ArmVirtPkg/ArmVirtCloudHv.dsc";
      x86_64 = "OvmfPkg/CloudHv/CloudHvX64.dsc";
    }
    .${stdenv.hostPlatform.parsed.cpu.name}
      or (throw "Unsupported OVMF `projectDscPath` on ${stdenv.hostPlatform.parsed.cpu.name}"),
  secureBoot ? false,
  # Usually, this option is broken, do not use it except if you know what you are
  # doing.
  sourceDebug ? false,
  systemManagementModeRequired ? secureBoot && stdenv.hostPlatform.isx86,
  tlsSupport ? false,
  tpmSupport ? false,
}:

let
  cpuName = stdenv.hostPlatform.parsed.cpu.name;

  version = lib.getVersion edk2;

  OvmfPkKek1AppPrefix = "4e32566d-8e9e-4f52-81d3-5bb9715f9727";

  debian-edk-src = fetchFromGitLab {
    domain = "salsa.debian.org";
    hash = "sha256-n/6T5UBwW8U49mYhITRZRgy2tNdipeU4ZgGGDu9OTkg=";
    nonConeMode = true;
    owner = "qemu-team";
    repo = "edk2";
    rev = "refs/tags/debian/2025.02-8";

    sparseCheckout = [
      "debian/edk2-vars-generator.py"
      "debian/python"
      "debian/PkKek-1-*.pem"
      "debian/patches/OvmfPkg-X64-add-opt-org.tianocore-UninstallMemAttrPr.patch"
    ];
  };

  buildPrefix = "Build/*/*";

in

edk2.mkDerivation projectDscPath (finalAttrs: {
  inherit version;
  pname = "OVMF";

  outputs = [
    "out"
    "fd"
  ];

  patches = [
    (debian-edk-src + "/debian/patches/OvmfPkg-X64-add-opt-org.tianocore-UninstallMemAttrPr.patch")
  ];

  strictDeps = true;

  nativeBuildInputs = [
    util-linux
    nasm
    acpica-tools
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.bintools
    llvmPackages.llvm
  ];

  buildFlags =
    # IPv6 has no reason to be disabled.
    [ "-D NETWORK_IP6_ENABLE=TRUE" ]
    ++ lib.optionals debug [ "-D DEBUG_ON_SERIAL_PORT=TRUE" ]
    ++ lib.optionals sourceDebug [ "-D SOURCE_DEBUG_ENABLE=TRUE" ]
    ++ lib.optionals secureBoot [ "-D SECURE_BOOT_ENABLE=TRUE" ]
    ++ lib.optionals systemManagementModeRequired [ "-D SMM_REQUIRE=TRUE" ]
    ++ lib.optionals fdSize2MB [ "-D FD_SIZE_2MB" ]
    ++ lib.optionals fdSize4MB [ "-D FD_SIZE_4MB" ]
    ++ lib.optionals httpSupport [
      "-D NETWORK_HTTP_ENABLE=TRUE"
      "-D NETWORK_HTTP_BOOT_ENABLE=TRUE"
    ]
    ++ lib.optionals tlsSupport [ "-D NETWORK_TLS_ENABLE=TRUE" ]
    ++ lib.optionals tpmSupport [
      "-D TPM_ENABLE"
      "-D TPM2_ENABLE"
      "-D TPM2_CONFIG_ENABLE"
    ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Qunused-arguments";

  postInstall = ''
    mkdir -vp $fd/FV
    mv -v $out/FV/${fwPrefix}.fd $fd/FV
  '';

  buildConfig = if debug then "DEBUG" else "RELEASE";
  dontPatchELF = true;

  hardeningDisable = [
    "format"
    "stackprotector"
    "pic"
    "fortify"
  ];

  passthru =
    let
      prefix = "${finalAttrs.finalPackage.fd}/FV/${fwPrefix}";
    in
    {
      inherit secureBoot systemManagementModeRequired;
      firmware = "${prefix}.fd";
      mergedFirmware = "${prefix}.fd";
      # This will test the EFI firmware for the host platform as part of the NixOS Tests setup.
      tests.basic-systemd-boot = nixosTests.systemd-boot.basic;
      tests.secureBoot-systemd-boot = nixosTests.systemd-boot.secureBoot;
    };

  meta = {
    description = "Sample UEFI firmware for Cloud Hypervisor and KVM";
    homepage = "https://github.com/tianocore/tianocore.github.io/wiki/OVMF";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      messemar
    ];

    broken = stdenv.hostPlatform.isDarwin;
  };
})

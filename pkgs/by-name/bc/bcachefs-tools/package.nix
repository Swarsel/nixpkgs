{
  lib,
  stdenv,
  fetchFromGitHub,
  attr,
  cargo,
  fuse3,
  installShellFiles,
  keyutils,
  kmod,
  libaio,
  libsodium,
  libunwind,
  liburcu,
  libuuid,
  lz4,
  makeWrapper,
  nix-update-script,
  nixosTests,
  pkg-config,
  rust-bindgen,
  rustPlatform,
  rustc,
  udev,
  udevCheckHook,
  versionCheckHook,
  zlib,
  zstd,
  fuseSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bcachefs-tools";
  version = "1.38.8";

  src = fetchFromGitHub {
    owner = "koverstreet";
    repo = "bcachefs-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9sDE7ua3WMCfV9ZbwQdAbpatv2IhvcwHzzPr+/l2au0=";
  };

  outputs = [
    "out"
    "dkms"
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "target/release/bcachefs" "target/${stdenv.hostPlatform.rust.rustcTargetSpec}/release/bcachefs"

    substituteInPlace src/commands/mount.rs \
      --replace-fail 'std::process::Command::new("modprobe")' 'std::process::Command::new("${lib.getExe' kmod "modprobe"}")'
  '';

  nativeBuildInputs = [
    pkg-config
    cargo
    rustc
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    rust-bindgen
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    libaio
    keyutils
    lz4
    libsodium
    libunwind
    liburcu
    libuuid
    zstd
    zlib
    attr
    udev
  ]
  ++ lib.optional fuseSupport fuse3;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "VERSION=${finalAttrs.version}"
    "INITRAMFS_DIR=${placeholder "out"}/etc/initramfs-tools"
    "DKMSDIR=${placeholder "dkms"}"

    # Tries to install to the 'systemd-minimal' and 'udev' nix installation paths
    "PKGCONFIG_SERVICEDIR=$(out)/lib/systemd/system"
    "PKGCONFIG_UDEVDIR=$(out)/lib/udev"
  ]
  ++ lib.optional fuseSupport "BCACHEFS_FUSE=1";

  env = {
    CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;
    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" = "${stdenv.cc.targetPrefix}cc";
  };

  # FIXME: Try enabling this once the default linux kernel is at least 6.7
  doCheck = false; # needs bcachefs module loaded on builder
  checkFlags = [ "BCACHEFS_TEST_USE_VALGRIND=no" ];

  preCheck = lib.optionalString (!fuseSupport) ''
    rm tests/test_fuse.py
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd bcachefs \
      --bash <($out/sbin/bcachefs completions bash) \
      --zsh  <($out/sbin/bcachefs completions zsh) \
      --fish <($out/sbin/bcachefs completions fish)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    udevCheckHook
    versionCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-F1+FeAlYSqOxeWJI8vHShpXrOZqYXjNGvty/s6f6u8w=";
  };

  enableParallelBuilding = true;

  installFlags = [
    "install"
    "install_dkms"
  ];

  versionCheckProgramArg = "version";

  passthru = {
    # See NOTE in linux-kernels.nix
    kernelModule = import ./kernel-module.nix finalAttrs.finalPackage;

    tests = {
      inherit (nixosTests.installer) bcachefsSimple bcachefsEncrypted bcachefsMulti;
      smoke-test = nixosTests.bcachefs;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool for managing bcachefs filesystems";
    homepage = "https://bcachefs.org/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      davidak
      johnrtitor
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bcachefs";
    broken = stdenv.hostPlatform.isi686; # error: stack smashing detected
    downloadPage = "https://github.com/koverstreet/bcachefs-tools";
  };
})

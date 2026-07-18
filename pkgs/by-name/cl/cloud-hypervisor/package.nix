{
  lib,
  stdenv,
  fetchFromGitHub,
  dtc,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cloud-hypervisor";
  version = "53.0";

  src = fetchFromGitHub {
    owner = "cloud-hypervisor";
    repo = "cloud-hypervisor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fPTGf8bAITDA8QwllWbbGXA7tJ6p/SxRDfcBQVRvCTI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    zstd
  ]
  ++ lib.optional stdenv.hostPlatform.isAarch64 dtc;

  cargoHash = "sha256-+RbW/9ap/69MyODUk/bHBlH6ZuqYYIyKaarYSMQ2G7w=";
  env.OPENSSL_NO_VENDOR = true;
  env.ZSTD_SYS_USE_PKG_CONFIG = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoTestFlags = [
    "--workspace"
    "--exclude"
    "hypervisor" # /dev/kvm
    "--exclude"
    "net_util" # /dev/net/tun
    "--exclude"
    "vmm" # /dev/kvm
    "--"
    # io_uring syscalls are blocked by the Lix sandbox
    "--skip=formats"
    "--skip=io_impl::async_io::uring_data_io"
  ];

  separateDebugInfo = true;

  meta = {
    description = "Open source Virtual Machine Monitor (VMM) that runs on top of KVM";
    homepage = "https://github.com/cloud-hypervisor/cloud-hypervisor";
    changelog = "https://github.com/cloud-hypervisor/cloud-hypervisor/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      bsd3
    ];

    maintainers = with lib.maintainers; [
      qyliss
      phip1611
    ];

    platforms = [
      "aarch64-linux"
      "riscv64-linux"
      "x86_64-linux"
    ];

    mainProgram = "cloud-hypervisor";
  };
})

{
  lib,
  fetchFromGitHub,
  clangStdenv,
  elfutils,
  libbpf,
  libpcap,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:
let
  pname = "rustnet";
  version = "1.3.0";
in
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "domcyrus";
    repo = "rustnet";
    tag = "v${version}";
    hash = "sha256-E2ItYSnT3WRSgPb5B+HDAlAPPmSLdt8qnE+2TiXHPk8=";
  };

  nativeBuildInputs = [
    pkg-config
    versionCheckHook
  ];

  buildInputs = [
    elfutils
    libbpf
    libpcap
    zlib
  ];

  cargoHash = "sha256-B1IdFOKYNaLiq6t64mdR3zUUcvojevcV6/nqYGbsbAY=";

  # Set environment variables for libbpf-sys
  env = {
    LIBBPF_SYS_INCLUDE_PATH = "${libbpf}/include";
    LIBBPF_SYS_LIBRARY_PATH = "${libbpf}/lib";
  };

  checkFlags = [
    "--skip=network::platform::linux::interface_stats::tests::test_get_all_stats"
    "--skip=network::platform::linux::interface_stats::tests::test_list_interfaces"
  ];

  __structuredAttrs = true;

  # Required for libbpf-sys to build correctly
  hardeningDisable = [
    "zerocallusedregs"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "High-performance, cross-platform network monitoring terminal UI tool built with Rust";
    homepage = "https://github.com/domcyrus/rustnet";
    changelog = "https://github.com/domcyrus/rustnet/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dvaerum ];
    platforms = lib.platforms.linux;
    mainProgram = "rustnet";
  };
}

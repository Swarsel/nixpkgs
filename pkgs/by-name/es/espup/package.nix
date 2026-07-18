{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
  writableTmpDirAsHomeHook,
  xz,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "espup";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "esp-rs";
    repo = "espup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qpn50VbcIibe0B1N5GU2AOFLt3NWjxEVimCrhhdY6EU=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    bzip2
    openssl
    xz
    zstd
  ];

  cargoHash = "sha256-Apvy+jPA7xyw43Q2RSVc65TNHQMGcCz/I/qadiJkBss=";

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [
    # makes network calls
    "--skip=toolchain::rust::tests::test_xtensa_rust_parse_version"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd espup \
      --bash <($out/bin/espup completions bash) \
      --fish <($out/bin/espup completions fish) \
      --zsh <($out/bin/espup completions zsh)
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool for installing and maintaining Espressif Rust ecosystem";
    homepage = "https://github.com/esp-rs/espup/";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      knightpp
      beeb
    ];

    mainProgram = "espup";
  };
})

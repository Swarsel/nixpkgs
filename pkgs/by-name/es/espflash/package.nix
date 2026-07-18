{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "espflash";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "esp-rs";
    repo = "espflash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o+MbUXZZycskltIH2NBGg2TnxOZ4viyc3D16quR2jqQ=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-QvJsmjMTx+oVqP3TkbN4A1PLAxmy8jwX/dZZkwdrkf8=";
  # Needed to get openssl-sys to use pkg-config.
  env.OPENSSL_NO_VENDOR = 1;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd espflash \
      --bash <($out/bin/espflash completions bash) \
      --zsh <($out/bin/espflash completions zsh) \
      --fish <($out/bin/espflash completions fish)
  '';

  cargoBuildFlags = [
    "--exclude=xtask"
    "--workspace"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Serial flasher utility for Espressif SoCs and modules based on esptool.py";
    homepage = "https://github.com/esp-rs/espflash";
    changelog = "https://github.com/esp-rs/espflash/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "espflash";
  };
})

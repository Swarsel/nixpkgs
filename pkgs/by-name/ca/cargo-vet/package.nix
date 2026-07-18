{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-vet";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "cargo-vet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sdjvCMLM8ThWXbotjRIsbLYucDzGvFOktqo6OKB//RI=";
  };

  cargoHash = "sha256-3pfOq2VfHbtohdgv73TT480bjCjdNKPJE+m4SHeXfGA=";
  # the test_project tests require internet access
  checkFlags = [ "--skip=test_project" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to help projects ensure that third-party Rust dependencies have been audited by a trusted source";
    homepage = "https://mozilla.github.io/cargo-vet";
    changelog = "https://github.com/mozilla/cargo-vet/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      jk
      matthiasbeyer
      ilkecan
    ];

    mainProgram = "cargo-vet";
  };
})

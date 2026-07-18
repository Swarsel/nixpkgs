{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rune-languageserver";
  version = "0.14.1";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-0b8XGbMQqMolOdQEMjpwHAVI3A4fXemyCowN39qY16A=";
    pname = "rune-languageserver";
  };

  cargoHash = "sha256-QrzOpfDpG08IUoydvSoh0qxJ0vg86391NnyEyJeZr54=";

  env = {
    RUNE_VERSION = finalAttrs.version;
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Language server for the Rune Language, an embeddable dynamic programming language for Rust";
    homepage = "https://crates.io/crates/rune-languageserver";
    changelog = "https://github.com/rune-rs/rune/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "rune-languageserver";
    downloadPage = "https://github.com/rune-rs/rune";
  };
})

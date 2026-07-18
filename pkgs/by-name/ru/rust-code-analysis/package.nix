{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rust-code-analysis";
  version = "0.0.25";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-/Irmtsy1PdRWQ7dTAHLZJ9M0J7oi2IiJyW6HeTIDOCs=";
    pname = "rust-code-analysis-cli";
  };

  cargoHash = "sha256-HirLjKkfZfc9UmUcUF5WW7xAJuCu7ftJDH8+zTSYlxs=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Analyze and collect metrics on source code";
    homepage = "https://github.com/mozilla/rust-code-analysis";
    changelog = "https://github.com/mozilla/rust-code-analysis/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit # grammars
      mpl20 # code
    ];

    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "rust-code-analysis-cli";
  };
})

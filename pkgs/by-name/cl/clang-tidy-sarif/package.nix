{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clang-tidy-sarif";
  version = "0.8.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-ALwEsF1n6WYqITfYTn8mIyn3sxTbDux17FxKIorKkFc=";
  };

  cargoHash = "sha256-cTBXStAA+oCRze2Bh/trultdqtBNOOpXQltJ6R34nF8=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI tool to convert clang-tidy diagnostics into SARIF";
    homepage = "https://psastras.github.io/sarif-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "clang-tidy-sarif";
  };
})

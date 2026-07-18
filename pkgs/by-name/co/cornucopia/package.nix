{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cornucopia";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cornucopia-rs";
    repo = "cornucopia";
    tag = "cornucopia-v${finalAttrs.version}";
    hash = "sha256-qlhdBI8XadU2dMbBEGRzWbZMdCkzt5u5ywfcvuIEYC8=";
  };

  cargoHash = "sha256-Tm951lRd53Mzw9UwpDHQ11KRhk0Mj/XaGXcKqSE43cM=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  cargoBuildFlags = [ "--package=cornucopia" ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "cornucopia-v(.*)"
    ];
  };

  meta = {
    description = "Generate type-checked Rust from your PostgreSQL";
    homepage = "https://github.com/cornucopia-rs/cornucopia";
    changelog = "https://github.com/cornucopia-rs/cornucopia/blob/cornucopia-v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "cornucopia";
  };
})

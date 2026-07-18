{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-feature-combinations";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "romnn";
    repo = "cargo-feature-combinations";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PneHMWX7IRoX4oSm8iePeI+pEPs8n3F2PW06ZWKDFcc=";
  };

  cargoHash = "sha256-DCfO2N6ml1a1P2hFs3gxRE9k+WYv8eqMzwL+cionwYE=";
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cargo plugin to run commands against all combinations of features";
    homepage = "https://github.com/romnn/cargo-feature-combinations";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      pinage404
    ];

    mainProgram = "cargo-feature-combinations";
  };
})

{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sampo";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "bruits";
    repo = "sampo";
    tag = "cargo-sampo-v${finalAttrs.version}";
    hash = "sha256-WGK2B6SzZNnclD2HeurXLujlScTZaI+jQbOaOrAt8Xw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-WY+LYVxEo5FEon3pv/OHiDUZDXSaPot7PIgdOTXpWII=";
  env.OPENSSL_NO_VENDOR = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  # Disable self-update
  buildNoDefaultFeatures = true;

  cargoBuildFlags = [
    "-p"
    "sampo"
  ];

  cargoTestFlags = finalAttrs.cargoBuildFlags;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=cargo-sampo-v([0-9\\.]*)" ];
  };

  meta = {
    description = "Automate changelogs, versioning, and publishing—even for monorepos across multiple package registries";
    homepage = "https://github.com/bruits/sampo";
    changelog = "https://github.com/bruits/sampo/blob/${finalAttrs.src.tag}/crates/sampo/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "sampo";
  };
})

{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-sbom";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "psastras";
    repo = "sbom-rs";
    tag = "cargo-sbom-v${finalAttrs.version}";
    hash = "sha256-U11tUXhUD0RjnTuTSmQwBD7OSsYXBfeofDfURDwbGrc=";
  };

  cargoHash = "sha256-a0tGBTCLvYUObFeZwSxEqRPpMkEZdsO4kHnExUMrNWk=";

  checkFlags = [
    "--skip=test_cargo_binary_cyclonedx_1_5_example"
    "--skip=test_cargo_binary_cyclonedx_1_6_example"
    "--skip=test_cargo_binary_cyclonedx_example"
    "--skip=test_cargo_binary_spdx_example"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Create software bill of materials (SBOM) for Rust";
    homepage = "https://github.com/psastras/sbom-rs";
    license = [ lib.licenses.mit ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    platforms = lib.platforms.all;
    mainProgram = "cargo-sbom";
  };
})

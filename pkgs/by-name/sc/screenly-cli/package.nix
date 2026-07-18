{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "screenly-cli";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "screenly";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1Trq1LFmKtzCCuqOT3DeL5KAPtHWi/glmhLBTR2vdVg=";
  };

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-VPl9/5GkMI2oZQ9ZUwpMcW9+3SCbCpLCVrBiXneCakQ=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools for managing digital signs and screens at scale";
    homepage = "https://github.com/Screenly/cli";
    changelog = "https://github.com/Screenly/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vpetersson
    ];

    mainProgram = "screenly";
  };
})

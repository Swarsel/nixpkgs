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
  pname = "nixpkgs-track";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "uncenter";
    repo = "nixpkgs-track";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wxmM69bUp98CS4oCYhaliH7fRts9+Ay/JjhuP5IMgeE=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-lnv0nCyb2+7Xl+qAAeaHdbk4XOGdq4FINxPOIPchDhg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Track where Nixpkgs pull requests have reached";
    homepage = "https://github.com/uncenter/nixpkgs-track";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      isabelroses
      uncenter
      matthiasbeyer
    ];

    mainProgram = "nixpkgs-track";
  };
})

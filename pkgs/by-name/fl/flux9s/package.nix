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
  pname = "flux9s";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "dgunzy";
    repo = "flux9s";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eX9qLhxSieZGxyLrHb2txrxekMElLIOeuVuxmOZH4Ak=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-bAgkDJnmcvH3aGhLjY1hn+tnAYmuDFewQ12K8qKTnsY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "K9s-inspired terminal UI for monitoring Flux GitOps resources in real-time";
    homepage = "https://flux9s.ca/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "flux9s";
  };
})

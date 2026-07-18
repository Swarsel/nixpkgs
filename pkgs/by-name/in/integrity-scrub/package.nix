{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "integrity-scrub";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "illdefined";
    repo = "integrity-scrub";
    tag = finalAttrs.version;
    hash = "sha256-OLO64R9AYpHSkIwk2arka5EEzCWusZPWsBhy5HEDIQI=";
  };

  cargoHash = "sha256-sS4z5NImUdk0EnQ+BGPofFZtXZsomfUXXbHNDmVqAos=";
  # Requires unstable features
  env.RUSTC_BOOTSTRAP = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scrub dm-integrity devices";
    homepage = "https://github.com/illdefined/integrity-scrub";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ mvs ];
    platforms = lib.platforms.linux;
    mainProgram = "integrity-scrub";
  };
})

{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ghdump";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "drupol";
    repo = "ghdump";
    tag = finalAttrs.version;
    hash = "sha256-UNIG/AT5RGPeNfZ7S3TdhfN+s8VXRPygcTBV7Fulilg=";
  };

  strictDeps = true;
  cargoHash = "sha256-gyNMtS6h2ct9IkvfhRWyMv9JVPtVEILsmYUcPETFEWQ=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Export GitHub issues, pull requests, and discussions through customizable templates";
    homepage = "https://github.com/drupol/ghdump";
    changelog = "https://github.com/drupol/ghdump/releases/tag/${finalAttrs.version}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "ghdump";
  };
})

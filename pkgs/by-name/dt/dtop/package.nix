{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dtop";
  version = "0.7.9";

  src = fetchFromGitHub {
    owner = "amir20";
    repo = "dtop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1OHtMV2GmZQIx2pVujOXoQOkc6hJdJZjca4kk4HyESM=";
  };

  cargoHash = "sha256-OHjgG5qHBz0Q74uWLkN9Ok0NiVeT71qpEjzFdMFWlfs=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal dashboard for Docker monitoring across multiple hosts with Dozzle integration";
    homepage = "https://dtop.dev/";
    changelog = "https://github.com/amir20/dtop/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kpbaks ];
    mainProgram = "dtop";
    downloadPage = "https://github.com/amir20/dtop";
  };
})

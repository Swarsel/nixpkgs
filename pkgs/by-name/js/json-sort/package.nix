{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "json-sort";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "drupol";
    repo = "json-sort";
    tag = finalAttrs.version;
    hash = "sha256-Xs1dMtPUmunkExQQ6IRmfFNz/3hVbARdtAL6K2Ur0ZQ=";
  };

  cargoHash = "sha256-RrNgmQ5v5zCKz/XaaLub16URmurQxfYTeNxy6UswFYY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dontUseCargoParallelTests = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool to sort JSON object keys in-place, preserving formatting and comments";
    homepage = "https://github.com/drupol/json-sort";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
    mainProgram = "json-sort";
  };
})

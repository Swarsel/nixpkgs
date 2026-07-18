{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typos";
  version = "1.48.0";

  src = fetchFromGitHub {
    owner = "crate-ci";
    repo = "typos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bXKdfq056p0gkbgEDysmHmIkZB0DowKZLlQA+93Fkuw=";
  };

  cargoHash = "sha256-RlxKciOdzzvy8hweSBAy64hPJFmNRUgqEb7zbPQvrbc=";

  preCheck = ''
    export LC_ALL=C.UTF-8
  '';

  postCheck = ''
    unset LC_ALL
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Source code spell checker";
    homepage = "https://github.com/crate-ci/typos";
    changelog = "https://github.com/crate-ci/typos/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      mgttlinger
      chrjabs
    ];

    mainProgram = "typos";
  };
})

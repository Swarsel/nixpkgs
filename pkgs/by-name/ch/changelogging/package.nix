{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "changelogging";
  version = "0.7.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-orTUCBHacD0MQNfhOUWdh9RxT/9YNvgfCHFDr2eNQic=";
  };

  cargoHash = "sha256-2uYNwKjD0vX+C2Sj2epyTqe4sMqPa7cwVwoUHs3vtQE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool for building changelogs from fragments";
    homepage = "https://github.com/nekitdev/changelogging";
    changelog = "https://github.com/nekitdev/changelogging/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nekitdev ];
    platforms = lib.platforms.all;
    mainProgram = "changelogging";
  };
})

{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  versionCheckHook,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gitmoji-cli";
  version = "9.7.0";

  src = fetchFromGitHub {
    owner = "carloscuesta";
    repo = "gitmoji-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2nQCxmZdDMKHcmVihloU4leKRB9LRBO4Q5AINR1vdCQ=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-YemcF7hRg+LAkR3US1xAgE0ELAeZTVLhscOphjmheRI=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  versionCheckProgram = "${placeholder "out"}/bin/gitmoji";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Gitmoji client for using emojis on commit messages";
    homepage = "https://github.com/carloscuesta/gitmoji-cli";
    changelog = "https://github.com/carloscuesta/gitmoji-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      yzx9
    ];

    mainProgram = "gitmoji";
  };
})

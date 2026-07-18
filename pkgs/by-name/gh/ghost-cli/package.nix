{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  versionCheckHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ghost-cli";
  version = "1.28.6";

  src = fetchFromGitHub {
    owner = "TryGhost";
    repo = "Ghost-CLI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GUdo2qn+5YOefCSHlH+jv+gSZWlT8POzQlaN0+Yxuhk=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/ghost";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-B39MyCn4P8iqT/y2wPeHKJgYWzgB4I81usmzC0PH3qU=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI Tool for installing & updating Ghost";
    homepage = "https://ghost.org/docs/ghost-cli/";
    changelog = "https://github.com/TryGhost/Ghost-CLI/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cything ];
    mainProgram = "ghost";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "spellchecker-cli";
  version = "7.0.3";

  src = fetchFromGitHub {
    owner = "tbroadley";
    repo = "spellchecker-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4rKUxXsZKsRDhMV0HL39yQyVNI0negCg97KsI+77oI4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  __structuredAttrs = true;
  yarnBuildScript = "prepack";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-GWIjk8eV2yYwsAfe7IY2mjO/dk9mb4vXEOvp68y4eMk=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A command-line tool for spellchecking files";
    homepage = "https://www.npmjs.com/package/spellchecker-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ WiredMic ];
    mainProgram = "spellchecker";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  yarnConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dotenv-cli";
  version = "11.0.0";

  src = fetchFromGitHub {
    owner = "entropitor";
    repo = "dotenv-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oPgi2l6YNt7WyaOzr7EkjgXOitpw9PY7tmN86bUM88Q=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    npmHooks.npmInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-I/DzRBETcusE4YS3nC47I1igsVzophNXoVtcD+upZPc=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI to load dotenv files";
    homepage = "https://github.com/entropitor/dotenv-cli";
    changelog = "https://github.com/entropitor/dotenv-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "dotenv";
  };
})

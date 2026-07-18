{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  versionCheckHook,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "remod";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "samuela";
    repo = "remod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7tLxvh/pLlt3Y+PkNF0s5f/wh/wGdeDtt0dc4eQqWlw=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  yarnBuildScript = "prepare";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-94i1wduLWCGHZNoohhBfjt3i2qsWr6UznKLHXH4im+c=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "chmod for human beings";
    homepage = "https://github.com/samuela/remod";
    changelog = "https://github.com/samuela/remod/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "remod";
  };
})

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
  pname = "patch-package";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "ds300";
    repo = "patch-package";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QuCgdQGqy27wyLUI6w6p8EWLn1XA7QbkjpLJwFXSex8=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-WF9gJkj4wyrBeGPIzTOw3nG6Se7tFb0YLcAM8Uv9YNI=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fix broken node modules instantly";
    homepage = "https://github.com/ds300/patch-package";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "patch-package";
  };
})

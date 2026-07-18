{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asar";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "electron";
    repo = "asar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-12FP8VRDo1PQ+tiN4zhzkcfAx9zFs/0MU03t/vFo074=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-/fV3hd98pl46+fgmiMH9sDQrrZgdLY1oF9c3TaIxRSg=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  meta = {
    description = "Simple extensive tar-like archive format with indexing";
    homepage = "https://github.com/electron/asar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xvapx ];
    mainProgram = "asar";
  };
})

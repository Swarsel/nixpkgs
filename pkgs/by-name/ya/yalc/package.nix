{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  stdenvNoCC,
  unstableGitUpdater,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yalc";
  version = "0-unstable-2023-07-04";

  src = fetchFromGitHub {
    owner = "wclr";
    repo = "yalc";
    # Upstream has no tagged versions
    rev = "3b834e488837e87df47414fd9917c10f07f0df08";
    hash = "sha256-v8OhLVuRhnyN2PrslgVVS0r56wGhYYmjoz3ZUZ95xBc=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-+w3azJEnRx4v3nJ3rhpLWt6CjOFhMMmr1UL5hg2ZR48=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Work with yarn/npm packages locally like a boss";
    homepage = "https://github.com/wclr/yalc";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "yalc";
  };
})

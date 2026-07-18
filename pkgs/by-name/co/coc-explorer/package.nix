{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "coc-explorer";
  version = "0.27.3";

  src = fetchFromGitHub {
    owner = "weirongxu";
    repo = "coc-explorer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lIJloatVEKPM36GE/xpVk+cx8Jz89BWU8qsNjc1eoFw=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  yarnBuildScript = "build:pack";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-w2La2GTJfHjn6qaVQaHsQp8V2KNx2hqDVuBJUYk6WKg=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Explorer for coc.nvim";
    homepage = "https://github.com/weirongxu/coc-explorer";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})

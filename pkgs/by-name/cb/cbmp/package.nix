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
  pname = "cbmp";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "ful1e5";
    repo = "cbmp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vOEz2KGJLCiiX+Or9y0JE9UF7sYbwaSCVm5iBv4jIdI=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-9iGfwMyy+cmIp7A5qOderuyL/0wrJ/zCTFPyLL/w3qE=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI App for converting cursor svg files to png";
    homepage = "https://github.com/ful1e5/cbmp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mrtnvgr ];
    mainProgram = "cbmp";
  };
})

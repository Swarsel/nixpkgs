{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  pnpmConfigHook,
  pnpm_10,
  versionCheckHook,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ni";
  version = "30.2.0";

  src = fetchFromGitHub {
    owner = "antfu-collective";
    repo = "ni";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H+gmiy+sHdiK5rRpOvkUe54kc/66J9eI9kIMfFcjTrg=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    npmHooks.npmInstallHook
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build
    find dist -type f \( -name '*.cjs' -or -name '*.cts' -or -name '*.ts' \) -delete

    runHook postBuild
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontNpmPrune = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-OxGdTKzGliGshBWlx+5rxVSN1QWTsQKHzJXynnlCUg0=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Use the right package manager";
    homepage = "https://github.com/antfu-collective/ni";
    changelog = "https://github.com/antfu-collective/ni/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    mainProgram = "ni";
  };
})

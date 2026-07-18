{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  pnpmConfigHook,
  pnpm_11,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "taze";
  version = "19.14.1";

  src = fetchFromGitHub {
    owner = "antfu-collective";
    repo = "taze";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tcyZ4nbMw+RjASQKOiMDUCYNSWBeJ0u/rQ9Dq81HA7Y=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_11
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
    fetcherVersion = 4;
    hash = "sha256-6J7yNwtekfMfsqeXWpNeqw4cak7z03494nYlBHRMZH0=";
    pnpm = pnpm_11;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern cli tool that keeps your deps fresh";
    homepage = "https://github.com/antfu-collective/taze";
    changelog = "https://github.com/antfu-collective/taze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    mainProgram = "taze";
  };
})

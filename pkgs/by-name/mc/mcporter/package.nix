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
  pname = "mcporter";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "openclaw";
    repo = "mcporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dfbNyvIbdhZOLuwRDNLqUJHVeMEemioanktD6nL0Pmk=";
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
    hash = "sha256-EGG9ycEMssFE4MOiXL5YuCRiXEaP//3boceR3d7/VQo=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TypeScript runtime and CLI for connecting to configured Model Context Protocol servers";
    homepage = "https://github.com/openclaw/mcporter";
    changelog = "https://github.com/openclaw/mcporter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mkg20001 ];
    mainProgram = "mcporter";
  };
})

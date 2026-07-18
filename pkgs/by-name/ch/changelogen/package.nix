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
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "changelogen";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "unjs";
    repo = "changelogen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N6X9Wffl9WumCXvAt4y+vs3ZJY7NheK+O8BObmuIa/g=";
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

  dontNpmPrune = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-S+GxeljcPj/MzBkleVNgaRa8D4kmHrKwwVqakmB5sAw=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Beautiful Changelogs using Conventional Commits";
    homepage = "https://github.com/unjs/changelogen";
    changelog = "https://github.com/unjs/changelogen/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ higherorderlogic ];
    platforms = nodejs.meta.platforms;
    mainProgram = "changelogen";
  };
})

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
  pname = "mgrep";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "mixedbread-ai";
    repo = "mgrep";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Njs0h2Roqm9xK8TV7BqrR5EwpK+ONNl3ct1fHU0UZEY=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    npmHooks.npmInstallHook
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  dontNpmPrune = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-T1mbRDBLU4SjZSgqyKgusZe5UV9hI+/bAmBYoAWcWtQ=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Semantic grep for local files using Mixedbread embeddings";
    homepage = "https://github.com/mixedbread-ai/mgrep";
    changelog = "https://github.com/mixedbread-ai/mgrep/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ andrewgazelka ];
    mainProgram = "mgrep";
  };
})

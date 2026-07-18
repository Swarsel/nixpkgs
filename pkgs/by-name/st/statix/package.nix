{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  withJson ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "statix";
  version = "0.5.8-unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "molybdenumsoftware";
    repo = "statix";
    rev = "7cbd82249a0154836db6118bec97da06ab447013";
    hash = "sha256-3n3hDc52+hAj1TWr3TFAeWzyDkaprsHafZVAlcS2WAM=";
  };

  cargoHash = "sha256-Ed0eSGhx0D1oZS44ObS3j1TuM3A1HnDKzDjDVYlX1jM=";
  __structuredAttrs = true;
  buildFeatures = lib.optional withJson "json";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Lints and suggestions for the nix programming language";
    homepage = "https://github.com/molybdenumsoftware/statix";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mightyiam
      nerdypepper
      progrm_jarvis
    ];

    mainProgram = "statix";
  };
})

{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "meilisearch";
  version = "1.49.0";

  src = fetchFromGitHub {
    owner = "meilisearch";
    repo = "meilisearch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-obUX84KNeJzkuRjOFBtLmCo/lcq0AwsaY/WDgaLhN2k=";
  };

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  cargoHash = "sha256-1UjXuvzT3gN0byKtYs6fv6xyKAi4uPBip9l+r6I1lHU=";
  # Tests will try to compile with mini-dashboard features which downloads something from the internet.
  doCheck = false;
  # Default features include mini dashboard which downloads something from the internet.
  buildNoDefaultFeatures = true;
  cargoBuildFlags = [ "--package=meilisearch" ];

  passthru = {
    tests = {
      meilisearch = nixosTests.meilisearch;
    };

    updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };
  };

  meta = {
    description = "Powerful, fast, and an easy to use search engine";
    homepage = "https://docs.meilisearch.com/";
    changelog = "https://github.com/meilisearch/meilisearch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      happysalada
      bbenno
    ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "meilisearch";
  };
})

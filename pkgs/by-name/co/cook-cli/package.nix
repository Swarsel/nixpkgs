{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cook-cli";
  version = "0.32.1";

  src = fetchFromGitHub {
    owner = "cooklang";
    repo = "cookcli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-r6h7IHYvy3/3OS+6aueHj9ONXSYJ1K7gq7pcNTqN8wY=";
  };

  nativeBuildInputs = [
    pkg-config
    openssl
    nodejs
    npmHooks.npmConfigHook
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-agUqBXhLsjS1nVRwzuiUZomhcYdiXBLU1xX9xh8zN+c=";
  env.OPENSSL_NO_VENDOR = 1;

  preBuild = ''
    npm run build-css
    npm run build-js
  '';

  # Build without the self-updating feature
  buildNoDefaultFeatures = true;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-tBOBa2plgJ0dG5eDD9Yc9YS+Dh6rhBdqU6JiZUjTUY4=";
  };

  meta = {
    description = "Suite of tools to create shopping lists and maintain recipes";
    homepage = "https://cooklang.org/";
    changelog = "https://github.com/cooklang/cookcli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.emilioziniades
      lib.maintainers.ginkogruen
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "cook";
  };
})

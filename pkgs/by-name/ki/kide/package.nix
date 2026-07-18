{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kide";
  version = "1.0.40";

  src = fetchFromGitHub {
    owner = "openobserve";
    repo = "kide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lRkFPS+hkACj3CxWde4B7phHUMh+2643Jgd0Wt3nUSo=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
  ];

  cargoHash = "sha256-/PdUaSW7YMFDgMFqA+7ePNPraPhMSNqFaONIEFubtNc=";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-1BY2oEnpldl+m8hUg9bszAyR67M8ErbcNaNE676c9hU=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (cargo-tauri.hook.meta) platforms;
    description = "Fast and lightweight Kubernetes IDE";
    homepage = "https://github.com/openobserve/kide";
    changelog = "https://github.com/openobserve/kide/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "kide";
  };
})

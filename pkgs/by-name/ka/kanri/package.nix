{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  fetchYarnDeps,
  glib-networking,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
  yarnBuildHook,
  yarnConfigHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kanri";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "kanriapp";
    repo = "kanri";
    tag = "app-v${finalAttrs.version}";
    hash = "sha256-HPwCU08cOkQre7ce9IxTbhwf3vi80VTpuLCoIT6b424=";
  };

  nativeBuildInputs = [
    nodejs
    cargo-tauri.hook

    yarnConfigHook
    yarnBuildHook

    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-efzchVrdjcfwLtRd87S4bK6Kqrfcdwthw1F0s557u/Y=";

  preBuild = ''
    yarn --offline generate
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-PBhn0VTt+6rf7YTuoVf3L4a6+AoXuad4E20dWiGVOOE=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern, minimalist Kanban board that works offline";
    homepage = "https://www.kanriapp.com/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ miampf ];
    mainProgram = "kanri";
  };
})

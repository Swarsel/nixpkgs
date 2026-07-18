{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  dbus,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  pkg-config,
  restic,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "restic-browser";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "emuell";
    repo = "restic-browser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K8JEt1kOvu/G3S1O6W/ee2JM968bgPR/FeGaBKP6elU=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook

    nodejs
    npmHooks.npmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    dbus
    restic
  ];

  cargoHash = "sha256-/EgSr46mJV84s/MG/3nUnU6XQ8RtEWiWo0gFtegblEQ=";

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    ln -s $out/Applications/Restic-Browser.app/Contents/MacOS/Restic-Browser $out/bin/${finalAttrs.meta.mainProgram}
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-uyn5cXMKm7+LLuF+n94pBTypLiPvfAs5INDEtd9cHs0=";
    name = "${finalAttrs.pname}-npm-deps-${finalAttrs.version}";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI to browse and restore restic backup repositories";
    homepage = "https://github.com/emuell/restic-browser";
    changelog = "https://github.com/emuell/restic-browser/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ js6pak ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "restic-browser";
  };
})

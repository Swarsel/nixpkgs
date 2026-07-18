{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  copyDesktopItems,
  fetchNpmDeps,
  glib-networking,
  makeDesktopItem,
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
  pname = "flying-carpet";
  version = "9.0.10";

  src = fetchFromGitHub {
    owner = "spieglt";
    repo = "FlyingCarpet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7yGU4HCuP8/6UC1J6fNA5CpppJGGhS/ywThXRToDTqo=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    wrapGAppsHook4
    copyDesktopItems
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-/Z+0hdQ1H9R7FMLunGT5WgQKFY0b0b6gzrR2CNMe2II=";

  checkFlags = [
    "--skip"
    "network"
  ];

  postInstall = ''
    install -Dm644 "Flying Carpet/src-tauri/icons/32x32.png" "$out/share/icons/hicolor/32x32/apps/FlyingCarpet.png"
    install -Dm644 "Flying Carpet/src-tauri/icons/128x128.png" "$out/share/icons/hicolor/128x128/apps/FlyingCarpet.png"
    install -Dm644 "Flying Carpet/src-tauri/icons/128x128@2x.png" "$out/share/icons/hicolor/256x256@2/apps/FlyingCarpet.png"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      desktopName = "FlyingCarpet";
      exec = "FlyingCarpet";
      icon = "FlyingCarpet";
      name = "FlyingCarpet";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Send and receive files between Android, iOS, Linux, macOS, and Windows over ad hoc WiFi";
    homepage = "https://github.com/spieglt/FlyingCarpet";
    changelog = "https://github.com/spieglt/FlyingCarpet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux; # No darwin: https://github.com/spieglt/FlyingCarpet/issues/117
    mainProgram = "FlyingCarpet";
  };
})

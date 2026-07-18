{
  lib,
  fetchFromGitHub,
  cairo,
  cargo-tauri,
  dbus,
  desktop-file-utils,
  fetchYarnDeps,
  gdk-pixbuf,
  glib,
  gtk3,
  nodejs,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
  yarnConfigHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "catppuccinifier-gui";
  version = "9.1.0";

  src = fetchFromGitHub {
    owner = "lighttigerXIV";
    repo = "catppuccinifier";
    tag = finalAttrs.version;
    hash = "sha256-e8sLYp+0YhC/vAn4vag9UUaw3VYDRERGnLD1RuW1TXE=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    nodejs
    yarnConfigHook
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    cairo
    gdk-pixbuf
    glib
    dbus
  ];

  cargoHash = "sha256-BUXqPY3jNn4YB1avtCp6MFyN1KIYqT0b1H9drOmikj0=";

  postInstall = ''
    desktop-file-edit "$out/share/applications/catppuccinifier-gui.desktop" \
      --set-key "Categories" --set-value "Graphics" \
      --set-key "Comment" --set-value "Apply catppuccin flavors to your wallpapers"
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";
  sourceRoot = finalAttrs.src.name + "/src/catppuccinifier-gui";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-UfQZf2raMrgPhUQVTAW+mA/nP1XjLKx0WBbYtdeD9kY=";
    yarnLock = finalAttrs.src + "/src/catppuccinifier-gui/yarn.lock";
  };

  meta = {
    description = "Apply catppuccin flavors to your wallpapers";
    homepage = "https://github.com/lighttigerXIV/catppuccinifier";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    platforms = lib.platforms.linux;
    mainProgram = "catppuccinifier-gui";
  };
})

{
  lib,
  fetchFromGitHub,
  bzip2,
  cairo,
  cargo-tauri,
  desktop-file-utils,
  fetchPnpmDeps,
  fontconfig,
  gdk-pixbuf,
  glib,
  glib-networking,
  gst_all_1,
  gtk3,
  libsoup_3,
  makeDesktopItem,
  nix-update-script,
  nodejs,
  openssl,
  pango,
  pkg-config,
  pnpmConfigHook,
  pnpm_11,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "deadlock-mod-manager";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "deadlock-mod-manager";
    repo = "deadlock-mod-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tSOSjapAlAd63Xkc+MNFVKn1k4+AtW3w3GhicRTV9Pg=";
  };

  patches = [
    ./no-updater-artifacts.patch
  ];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo-tauri.hook
    nodejs
    pnpmConfigHook
    pnpm_11
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    cairo
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    libsoup_3
    pango
    openssl
    bzip2
    desktop-file-utils
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  cargoHash = "sha256-x0lhn8nAV9xTgWbRAabJscATSCNpkKpzWvdnuZ4BEvw=";
  env.VITE_API_URL = "https://api.deadlockmods.app";

  checkFlags = [
    # Requires network access
    "--skip=download_manager::downloader::tests::test_download_file"
    # Asserts that set_steam_dir rejects a non-Steam directory, but steamlocate
    # 2.1.0's SteamDir::from_dir only checks that the path is a directory
    # (further validation is an upstream TODO), so this fails in any environment.
    "--skip=mod_manager::steam_manager::tests::set_steam_dir_rejects_invalid_directory"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --set FONTCONFIG_FILE "${fontconfig.out}/etc/fonts/fonts.conf"
      --set TAURI_DIST_DIR "$out/share/deadlock-modmanager/dist"
      --set DISABLE_UPDATE_DESKTOP_DATABASE 1
      --prefix PATH : ${lib.makeBinPath [ desktop-file-utils ]}
      --add-flags "--disable-auto-update"
    )
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "apps/desktop";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Game"
      ];

      desktopName = "deadlock-mod-manager";
      exec = "deadlock-mod-manager %u";
      icon = "deadlock-mod-manager";
      mimeTypes = [ "x-scheme-handler/deadlock-mod-manager" ];
      name = "Deadlock Mod Manager";
      terminal = false;
      type = "Application";
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    fetcherVersion = 4;
    hash = "sha256-ZxlP6zOwY9Fxa4BCqnUoCmci3lviHn7H3HU5SnmdrSU=";
    pnpm = pnpm_11;
    sourceRoot = "source";
  };

  pnpmRoot = ".";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Mod manager for the Valve game Deadlock";
    homepage = "https://github.com/deadlock-mod-manager/deadlock-mod-manager";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mistyttm
      schromp
    ];

    platforms = lib.platforms.linux;
    mainProgram = "deadlock-mod-manager";
  };
})

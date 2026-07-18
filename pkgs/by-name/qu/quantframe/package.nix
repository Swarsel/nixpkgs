{
  lib,
  fetchFromGitHub,
  cargo-tauri,
  fetchPnpmDeps,
  glib-networking,
  gst_all_1,
  gtk3,
  libayatana-appindicator,
  libsoup_3,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "quantframe";
  version = "1.6.12";

  src = fetchFromGitHub {
    owner = "Kenya-DK";
    repo = "quantframe-react";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IF+8filOXG+4nWpivyYknkT+hAg8nhG10Hfm79/m3Uc=";
  };

  patches = [
    ./0001-disable-telemetry.patch
    ./0002-sync-node-packages.patch
  ];

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": "v1Compatible"' '"createUpdaterArtifacts": false'
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook3
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  buildInputs = [
    openssl
    libsoup_3
    glib-networking
    gtk3
    libayatana-appindicator
    webkitgtk_4_1
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  cargoHash = "sha256-Ffy7dutFVQNZUFm9/iW0qPqUJ9bbRW6PeuC3eNNqfk8=";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;

    fetcherVersion = 3;
    hash = "sha256-omomvnHUiEfGVJn6LApWOnRwSVO8kpMLN3Jz0MhwPpQ=";
    pnpm = pnpm_10;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Warframe Market listings and transactions manager";
    homepage = "https://quantframe.app/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nyukuru
      enkarterisi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "quantframe";
  };
})

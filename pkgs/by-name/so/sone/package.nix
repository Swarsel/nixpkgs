{
  lib,
  fetchFromGitHub,
  alsa-lib,
  cargo-tauri,
  dbus,
  fetchPnpmDeps,
  glib-networking,
  gst_all_1,
  gtk3,
  librsvg,
  libsecret,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_11,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

let
  pnpm = pnpm_11;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sone";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "lullabyX";
    repo = "sone";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dVAVMcEr9cUPJetcVj9y9Lkj6LevJH0M7WYui43IjnY=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpm
    pnpmConfigHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    dbus
    glib-networking
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    gtk3
    librsvg
    libsecret
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-gsg/aKy+RpJFF6Q2P5O7btoeY4Q/A9D/w3s1nLvnp1Q=";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-vOfDSTu7AnZINejVwnIXdZJYlmHSljJpddRRQqlI7ko=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native Linux desktop client for TIDAL";
    homepage = "https://github.com/lullabyX/sone";
    changelog = "https://github.com/lullabyX/sone/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ andresilva ];
    platforms = lib.platforms.linux;
    mainProgram = "sone";
  };
})

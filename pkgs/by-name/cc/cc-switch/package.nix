{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  fetchPnpmDeps,
  glib-networking,
  jq,
  libayatana-appindicator,
  libsoup_3,
  makeDesktopItem,
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
  pname = "cc-switch";
  version = "3.16.5";

  src = fetchFromGitHub {
    owner = "farion1231";
    repo = "cc-switch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CrUoTfGAy+gi3gdcSlNyjwM2Rm4nahqDWdM6I9OQgPc=";
  };

  postPatch = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # libappindicator-sys dlopens libayatana-appindicator3.so.1 at runtime; autoPatchelf can't catch it.
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    jq
    nodejs
    pnpmConfigHook
    pnpm_10
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    copyDesktopItems
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    glib-networking
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-gX32xCiVKHQ0BIIB9GyWHessIW30zbTcMZLtPJycxn8=";

  # tauri-build embeds frontendDist (../dist) at compile time; populate it
  # before cargo build runs.
  preBuild = ''
    pnpm run build:renderer
  '';

  # Proxy startup test binds to a local address, which the darwin sandbox blocks.
  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=services::provider::tests::update_current_claude_provider_syncs_live_when_proxy_takeover_detected_without_backup"
  ];

  postInstall = ''
    rm -rf $out/lib
    install -Dm644 src-tauri/icons/32x32.png $out/share/icons/hicolor/32x32/apps/cc-switch.png
    install -Dm644 src-tauri/icons/128x128.png $out/share/icons/hicolor/128x128/apps/cc-switch.png
    install -Dm644 src-tauri/icons/128x128@2x.png $out/share/icons/hicolor/256x256/apps/cc-switch.png
  '';

  __structuredAttrs = true;
  buildAndTestSubdir = finalAttrs.cargoRoot;

  # cc_switch_lib is an internal staticlib+cdylib+rlib; only the binary is needed.
  # tauri/custom-protocol enables embedded-asset serving via `tauri://localhost/`;
  # without it, WKWebView/webkit2gtk fall through to devUrl (http://localhost:3000)
  # and blank-screen with NSURLErrorCannotConnectToHost.
  cargoBuildFlags = [
    "--bin"
    "cc-switch"
    "--features=tauri/custom-protocol"
  ];

  cargoRoot = "src-tauri";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Utility"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "CC Switch";
      exec = finalAttrs.meta.mainProgram;
      icon = "cc-switch";
      mimeTypes = [ "x-scheme-handler/ccswitch" ];
      name = "cc-switch";
      startupWMClass = "cc-switch";
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    fetcherVersion = 3;
    hash = "sha256-Vs+/KLICqciF7dnC3iRH9TFzNCtXDgOkWFPLxdwA0rE=";
    pnpm = pnpm_10;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "All-in-one assistant for Claude Code, Codex, OpenCode, Gemini CLI and other AI coding agents";
    homepage = "https://ccswitch.io";
    changelog = "https://github.com/farion1231/cc-switch/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ imcvampire ];
    platforms = lib.platforms.unix;
    mainProgram = "cc-switch";
    downloadPage = "https://github.com/farion1231/cc-switch";
  };
})

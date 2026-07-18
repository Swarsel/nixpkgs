{
  lib,
  fetchFromGitHub,
  cargo-tauri,
  fetchPnpmDeps,
  jq,
  libayatana-appindicator,
  libsoup_3,
  moreutils,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_9,
  rustPlatform,
  webkitgtk_4_1,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "overlayed";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "overlayeddev";
    repo = "overlayed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3GFg8czBf1csojXUNC51xFXJnGuXltP6D46fCt6q24I=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    # disable updater
    jq '.plugins.updater.endpoints = [ ] | .bundle.createUpdaterArtifacts = false' \
      apps/desktop/src-tauri/tauri.conf.json | sponge apps/desktop/src-tauri/tauri.conf.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    jq
    moreutils
    nodejs
    pkg-config
    pnpmConfigHook
    pnpm_9
  ];

  buildInputs = [
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-6wN4nZQWrY0J5E+auj17B3iJ/84hzBXYA/bJsX/N5pk=";

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  buildAndTestSubdir = "apps/desktop/src-tauri";
  cargoRoot = "apps/desktop/src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-KJZuucXB7BEMnqPmgytveG/IBEzq4mgMo9ZJHPe/gVs=";
    pnpm = pnpm_9;
  };

  meta = {
    description = "Modern discord voice chat overlay";
    homepage = "https://github.com/overlayeddev/overlayed";
    changelog = "https://github.com/overlayeddev/overlayed/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "overlayed";
  };
})

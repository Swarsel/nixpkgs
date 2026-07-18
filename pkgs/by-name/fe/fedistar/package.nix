{
  lib,
  fetchFromGitHub,
  cargo-tauri,
  fetchPnpmDeps,
  glib-networking,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  stdenvNoCC,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fedistar";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "h3poteto";
    repo = "fedistar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MV2ItwIBzDEY2tKI8WrQj+rAzv6OTC2aZMiD46oLHFw=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook

    pnpmConfigHook
    pnpm_10
    nodejs

    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
    glib-networking
    webkitgtk_4_1
  ];

  cargoHash = "sha256-Ac7u/u0kGlUwKF5/196Ss4+pUMyPhAbGqhlmtlYI2Us=";
  doCheck = false; # This version's tests do not pass
  buildAndTestSubdir = "src-tauri";
  cargoRoot = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-JaFXAYHoSMyNgHjeNWgJXJ8ZeU9wUi47N58L3QEd0FE=";
    pnpm = pnpm_10;
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Multi-column Fediverse client application for desktop";
    homepage = "https://fedistar.net/";
    changelog = "https://github.com/h3poteto/fedistar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ noodlez1232 ];
    mainProgram = "fedistar";
  };
})

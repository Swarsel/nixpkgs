{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tabularis";
  version = "0.9.12";

  src = fetchFromGitHub {
    owner = "debba";
    repo = "tabularis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kObjJ+C+0d/wLNt902yUPe8Cvss8d0ILeuo98vIiYDU=";
  };

  patches = [
    ./disable-updater.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cargo-tauri.hook

    nodejs
    pnpmConfigHook
    pnpm

    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
  ];

  cargoHash = "sha256-XYvwgZMJXM62kC8+DR06LygtTnL+8TLWyRZAgTQWf3Q=";
  env.OPENSSL_NO_VENDOR = 1;
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-S/XCypKyYlJtuISNiG8NtJzisAejiUwqPVltXEmVlZw=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (cargo-tauri.hook.meta) platforms;
    description = "Lightweight, developer-focused database management tool, built with Tauri and React";
    homepage = "http://tabularis.dev";
    changelog = "https://github.com/debba/tabularis/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "tabularis";
  };
})

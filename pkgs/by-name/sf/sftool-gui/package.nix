{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cargo-tauri,
  fetchPnpmDeps,
  glib-networking,
  libgudev,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  systemdLibs,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sftool-gui";
  version = "1.1.4-unstable-2026-04-16";

  src = fetchFromGitHub {
    owner = "OpenSiFli";
    repo = "sftool-gui";
    rev = "e182a5973a4e23f8af078f3480a8b2416d7439b3";
    hash = "sha256-6wYf0DNn5cjJTeuVfOB91RQP/E2YWr6PlGUnzZdwgNY=";
  };

  patches = [
    # We don't want tauri to bundle the built binaries as we only use them and not the
    # bundled .deb, .appimage, and so on. Bundling the binaries would also require a signing
    # key, which we don't have.
    ./disable-bundling.patch
  ];

  nativeBuildInputs = [
    cargo-tauri.hook
    pnpmConfigHook
    pnpm
    nodejs
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
    autoPatchelfHook
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking # Most Tauri apps need networking
    webkitgtk_4_1
    libgudev
    systemdLibs
  ];

  cargoHash = "sha256-hwQJnhWgPqQ3ZudCsEEuWoygYDcUKXgWz15dHZ+vR6Q=";
  # Set our Tauri source directory
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-DwDXfbwgt/OSNOQbzCBlathX9QDnbEsXZLsgB67LOEk=";
  };

  passthru = {
    inherit (finalAttrs) pnpmDeps;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Download tool for the SiFli family of chips";
    homepage = "https://github.com/OpenSiFli/sftool-gui";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "sftool";
  };
})

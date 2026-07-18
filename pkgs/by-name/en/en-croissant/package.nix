{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  fetchPnpmDeps,
  gst_all_1,
  jq,
  makeBinaryWrapper,
  moreutils,
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

let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "en-croissant";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "franciscoBSalgueiro";
    repo = "en-croissant";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xP/u3EABj11bylZKDpvBsuUF6QRmtArQV/pTY+0ANb0=";
  };

  postPatch = ''
    # disable updater and disable mac codesigning
    jq '
      .plugins.updater.endpoints = [ ] |
      .bundle.createUpdaterArtifacts = false |
      .bundle.macOS.signingIdentity = null
    ' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
  '';

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook

    cargo-tauri.hook
    jq
    moreutils
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook3 ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ makeBinaryWrapper ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
    webkitgtk_4_1

    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  cargoHash = "sha256-/L3URUdUIVrWHlXgRJfmDfFfOKGz9slDe49iE5nPw5k=";
  doCheck = false; # many scoring tests fail

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    makeWrapper "$out"/Applications/en-croissant.app/Contents/MacOS/en-croissant $out/bin/en-croissant
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-icJ5cU0ZNnYSZl+MPASNmGanc9Vaa61sotza8/G/xs4=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ultimate Chess Toolkit";
    homepage = "https://github.com/franciscoBSalgueiro/en-croissant/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      tomasajt
      snu
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "en-croissant";
  };
})

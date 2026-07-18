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
  pname = "pawn-appetit";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "Pawn-Appetit";
    repo = "pawn-appetit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3kpExWdZh4Y0ZwBttpqE/nALyUJNWSEOy8HLcfauReY=";
  };

  postPatch = ''
    jq '.plugins.updater.endpoints = [ ] | .bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
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

  cargoHash = "sha256-b+v16vF5Puyp23r32Y1HtOvkboA2R2HRs1ktyDBQd84=";
  doCheck = false; # many scoring tests fail

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    makeWrapper "$out"/Applications/pawn-appetit.app/Contents/MacOS/pawn-appetit $out/bin/pawn-appetit
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
    hash = "sha256-c4ckvmzosWrB5eXG/xpOH8mYgNNMgqBZ9q8yU7Pjve4=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ultimate Chess Toolkit (fork of en-croissant)";
    homepage = "https://github.com/Pawn-Appetit/pawn-appetit/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ snu ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "pawn-appetit";
  };
})

{
  lib,
  fetchurl,
  fetchFromGitHub,
  cargo-tauri,
  fetchPnpmDeps,
  glib-networking,
  jq,
  libsoup_3,
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
  inlangModules = [
    (fetchurl {
      hash = "sha256-IOyECYVo8YqD2jYePrrfWGImn6M1FQzJvVDXmaSP31c=";
      name = "plugin-message-format-index.js";
      url = "https://cdn.jsdelivr.net/npm/@inlang/plugin-message-format@4/dist/index.js";
    })
    (fetchurl {
      hash = "sha256-hYYvYwV5O1a/2a/lNosJbmP7Kuqzi3eZwFFRe+NJnAs=";
      name = "plugin-m-function-matcher-index.js";
      url = "https://cdn.jsdelivr.net/npm/@inlang/plugin-m-function-matcher@2/dist/index.js";
    })
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gale";
  version = "1.13.4";

  src = fetchFromGitHub {
    owner = "Kesomannen";
    repo = "gale";
    tag = finalAttrs.version;
    hash = "sha256-ZCHknOp6ll9q6OBW/5/mNcu0d0zZj1rkCjPiumjMVzk=";
  };

  postPatch = ''
    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json

    substituteInPlace project.inlang/settings.json ${
      lib.concatMapStringsSep " " (m: "--replace-fail ${m.url} ${m}") inlangModules
    }
  '';

  nativeBuildInputs = [
    jq
    moreutils
    pnpmConfigHook
    pnpm_10
    nodejs
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking # needed to load icons
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-kAPTiGHWO/eBapPcH8xItOFeZYC0URzLYdl2GMQ50Ls=";
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
    hash = "sha256-bCGiYVmoWjpwneTQUwetna7u29BMIv48qWgZ2gd93hQ=";
    pnpm = pnpm_10;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight Thunderstore client";
    homepage = "https://github.com/Kesomannen/gale";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      tomasajt
      notohh
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gale";
  };
})

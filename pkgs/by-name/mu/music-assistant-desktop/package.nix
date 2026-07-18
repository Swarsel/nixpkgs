{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  atk,
  # nativeBuildInputs
  cargo-tauri,
  dbus,
  fetchYarnDeps,
  glib-networking,
  gtk3,
  jq,
  libappindicator-gtk3,
  llvmPackages,
  moreutils,
  nodejs,
  # buildInputs
  openssl,
  pkg-config,
  pulseaudio,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "music-assistant-desktop";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "desktop-app";
    tag = finalAttrs.version;
    hash = "sha256-KKyIYSSIC134t46H7YOFNCdj4M/VoBrX9jN5aX/kSlc=";
  };

  patches = [
    ./remove-updater.diff
  ];

  postPatch = ''
    # set version
    substituteInPlace package.json src-tauri/tauri.conf.json \
      --replace-fail "0.0.0" "${finalAttrs.version}"

    # disable upstream updater
    jq '.plugins.updater.endpoints = [ ] | .bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
      | sponge src-tauri/tauri.conf.json
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cargo-tauri.hook
    jq
    moreutils
    nodejs
    pkg-config
    yarnBuildHook
    yarnConfigHook
    yarnInstallHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook3 ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    atk
    dbus
    glib-networking
    libappindicator-gtk3
    pulseaudio
    gtk3
    webkitgtk_4_1
  ];

  cargoHash = "sha256-AFn2m8eO+U86s6g2LlzBuAsJBesrm3Gncihf+zbPDeE=";

  env = {
    # `LIBCLANG_PATH` is needed to build `coreaudio-sys` on darwin
    LIBCLANG_PATH = lib.optionalString stdenv.hostPlatform.isDarwin "${lib.getLib llvmPackages.libclang}/lib";
  };

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libappindicator-gtk3 ]}"
    )
  '';

  __structuredAttrs = true;
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-dOJ5ETRodpnuaI+L2wckNU0XANUcjqzvdqw/cd5sJC4=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  meta = {
    description = "Official companion desktop app for Music Assistant";
    homepage = "https://github.com/music-assistant/desktop-app";
    changelog = "https://github.com/music-assistant/desktop-app/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nim65s ];
    platforms = lib.platforms.all;
    mainProgram = "music-assistant-companion";
  };
})

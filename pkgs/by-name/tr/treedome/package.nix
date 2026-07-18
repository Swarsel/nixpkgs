{
  lib,
  cargo-tauri,
  dbus,
  fetchYarnDeps,
  fetchgit,
  freetype,
  gsettings-desktop-schemas,
  libayatana-appindicator,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  webkitgtk_4_1,
  wrapGAppsHook4,
  yarnConfigHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "treedome";
  version = "0.6.1";

  src = fetchgit {
    url = "https://codeberg.org/solver-orgz/treedome";
    rev = finalAttrs.version;
    hash = "sha256-qa87pgNHGRhP1G4TEFHYrkiJ9AHWG7PUdgxEF4X9EM8=";
    fetchLFS = true;
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    wrapGAppsHook4
    yarnConfigHook
  ];

  buildInputs = [
    dbus
    openssl
    freetype
    webkitgtk_4_1
    libayatana-appindicator
    gsettings-desktop-schemas
    sqlite
  ];

  cargoHash = "sha256-Rg65BiHQF7bBBCtc5F+gY31yhcuI0+IDfxr3pFmxT+w=";

  env = {
    VERGEN_GIT_DESCRIBE = finalAttrs.version;
  };

  # WEBKIT_DISABLE_COMPOSITING_MODE essential in NVIDIA + compositor https://github.com/NixOS/nixpkgs/issues/212064#issuecomment-1400202079
  postFixup = ''
    wrapProgram "$out/bin/treedome" \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  offlineCache = fetchYarnDeps {
    hash = "sha256-Q0xsi1xymQne6qN0oxm4YkaDLnGL17iuj70CTdQlxzM=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  meta = {
    description = "Local-first, encrypted, note taking application organized in tree-like structures";
    homepage = "https://codeberg.org/solver-orgz/treedome";
    changelog = "https://codeberg.org/solver-orgz/treedome/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ tengkuizdihar ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "treedome";
  };
})

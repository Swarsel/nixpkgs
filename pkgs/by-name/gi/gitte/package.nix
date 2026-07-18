{
  lib,
  stdenv,
  appstream,
  cargo,
  desktop-file-utils,
  fetchFromCodeberg,
  gettext,
  glib,
  gtk4,
  libadwaita,
  libgit2,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gitte";
  version = "0.8.1";

  src = fetchFromCodeberg {
    owner = "ckruse";
    repo = "Gitte";
    tag = finalAttrs.version;
    hash = "sha256-c7GhPn7/0PzRTYQbhfvlSUMJqHs4dRqeWRMBJG2eqdc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
    desktop-file-utils
    appstream
    gettext
    glib
  ];

  buildInputs = [
    gtk4
    libadwaita
    openssl
    libgit2
    zlib
  ];

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-yR4MYQJQMjqEs++8RhQwDV+h/blSVgFqrGYUfrPUGOg=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK4/libadwaita Git client";
    homepage = "https://codeberg.org/ckruse/Gitte";
    license = with lib.licenses; [ agpl3Plus ];

    maintainers = with lib.maintainers; [
      ckruse
      orzklv
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gitte";
  };
})

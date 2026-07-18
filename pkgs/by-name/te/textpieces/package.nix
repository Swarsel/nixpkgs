{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textpieces";
  version = "4.3.1";

  src = fetchFromGitLab {
    owner = "liferooter";
    repo = "textpieces";
    tag = finalAttrs.version;
    hash = "sha256-BUhcPnvi6cuhaYYNZV9pvOLH/cIV3t7ncpG55fBjqwo=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cargo
    rustc
    rustPlatform.cargoSetupHook
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    gtksourceview5
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-bJKhakxHBhhqvgrFwEgaSNDI7cDaYQ+2SW/gSZzRvK0=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Swiss knife of text processing";

    longDescription = ''
      A small tool for quick text transformations such as
      checksums, encoding, decoding and so on.
    '';

    homepage = "https://gitlab.com/liferooter/textpieces";

    license = with lib.licenses; [
      gpl3Plus
      # and
      cc0
    ];

    maintainers = with lib.maintainers; [
      zendo
      liferooter
    ];

    platforms = lib.platforms.linux;
    mainProgram = "textpieces";
    teams = [ lib.teams.gnome-circle ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  gtk4,
  gtksourceview5,
  libadwaita,
  libspelling,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "buffer";
  version = "2026.1";

  src = fetchFromGitLab {
    owner = "cheywood";
    repo = "buffer";
    tag = finalAttrs.version;
    hash = "sha256-O2Kuw3UMHUP+PIyeXlgtUJC9/85tMk3ZL5SvWb+7gdU=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtksourceview5
    libadwaita
    libspelling
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src pname version;
    hash = "sha256-ipZgmk5Lb5LX6O6dSDVTetLN41VNJcAFJ+fNfkQnksc=";
  };

  meta = {
    description = "Minimal editing space for all those things that don't need keeping";
    homepage = "https://gitlab.gnome.org/cheywood/buffer";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ michaelgrahamevans ];
    platforms = lib.platforms.linux;
    mainProgram = "buffer";
  };
})

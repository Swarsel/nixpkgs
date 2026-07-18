{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  cargo,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pango,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "contrast";
  version = "0.0.11";

  src = fetchFromGitLab {
    owner = "design";
    repo = "contrast";
    tag = version;
    hash = "sha256-8A1qX1H0cET5AUvMoHC1/VyIQiaTysEY5RJRrVYvGng=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    glib
    gtk4
    libadwaita
    pango
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-Nj5MkYDeYUzgqegCbPt/XofSCw8ULFXAD7XHNecPznc=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Checks whether the contrast between two colors meet the WCAG requirements";
    homepage = "https://gitlab.gnome.org/World/design/contrast";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ getchoo ];
    platforms = lib.platforms.linux;
    mainProgram = "contrast";
  };
}

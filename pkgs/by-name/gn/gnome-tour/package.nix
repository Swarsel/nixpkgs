{
  lib,
  stdenv,
  fetchurl,
  appstream-glib,
  cargo,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk4,
  libadwaita,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-tour";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-tour/${lib.versions.major finalAttrs.version}/gnome-tour-${finalAttrs.version}.tar.xz";
    hash = "sha256-bOEYcDGjZb8iagzRRvF7R3Pn7UUIg/fNUC9ez0MrUyU=";
  };

  nativeBuildInputs = [
    appstream-glib
    cargo
    desktop-file-utils
    gettext
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    librsvg
  ];

  cargoVendorDir = "vendor";

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-tour";
    };
  };

  meta = {
    description = "GNOME Greeter & Tour";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-tour";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-tour/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-tour";
    teams = [ lib.teams.gnome ];
  };
})

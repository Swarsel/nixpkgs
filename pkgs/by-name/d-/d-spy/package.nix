{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk4,
  libadwaita,
  libdex,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "d-spy";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/d-spy/${lib.versions.major finalAttrs.version}/d-spy-${finalAttrs.version}.tar.xz";
    hash = "sha256-G93IbYos9ntPZS3EYczYNTES8Ih1NCADfHX1RU3qrRA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    wrapGAppsHook4
    gettext
    glib
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libdex
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "d-spy";
    };
  };

  meta = {
    description = "D-Bus exploration tool";
    homepage = "https://gitlab.gnome.org/GNOME/d-spy";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "d-spy";
    teams = [ lib.teams.gnome ];
  };
})

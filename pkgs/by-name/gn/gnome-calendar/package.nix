{
  lib,
  stdenv,
  fetchurl,
  blueprint-compiler,
  evolution-data-server-gtk4,
  fribidi,
  geoclue2,
  gettext,
  glib,
  glib-networking,
  gnome,
  gsettings-desktop-schemas,
  gtk4,
  libadwaita,
  libgweather,
  libical,
  libsoup_3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-calendar";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-calendar/${lib.versions.major finalAttrs.version}/gnome-calendar-${finalAttrs.version}.tar.xz";
    hash = "sha256-S3XfBxpS2Y+zXmR9AYAwEp0k2QB3kNAkV3RsmGF66rA=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    meson
    ninja
    pkg-config
    gettext
    libxml2
    wrapGAppsHook4
  ];

  buildInputs = [
    fribidi
    gtk4
    evolution-data-server-gtk4
    libical
    libsoup_3
    glib
    glib-networking
    libgweather
    geoclue2
    gsettings-desktop-schemas
    libadwaita
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-calendar";
    };
  };

  meta = {
    description = "Simple and beautiful calendar application for GNOME";
    homepage = "https://apps.gnome.org/Calendar/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-calendar";
    teams = [ lib.teams.gnome ];
  };
})

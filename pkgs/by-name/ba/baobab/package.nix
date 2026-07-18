{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk4,
  itstool,
  libadwaita,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "baobab";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/baobab/${lib.versions.major finalAttrs.version}/baobab-${finalAttrs.version}.tar.xz";
    hash = "sha256-VzyE8V9fljpEBQD29DQSySisIzX2tp3LWPGh/lIBAks=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    glib
    itstool
    libxml2
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "baobab";
    };
  };

  meta = {
    description = "Graphical application to analyse disk usage in any GNOME environment";
    homepage = "https://apps.gnome.org/Baobab/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "baobab";
    teams = [ lib.teams.gnome ];
  };
})

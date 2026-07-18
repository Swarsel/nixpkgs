{
  lib,
  stdenv,
  fetchurl,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  gnome,
  gobject-introspection,
  gtk4,
  itstool,
  json-glib,
  libadwaita,
  libgee,
  libxml2,
  meson,
  ninja,
  pkg-config,
  qqwing,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-sudoku";
  version = "50.2.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-sudoku/${lib.versions.major finalAttrs.version}/gnome-sudoku-${finalAttrs.version}.tar.xz";
    hash = "sha256-ZKtGEAg+eMiV4T4C/pUHj5f44DwKj6h83EKFv3KzO58=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gobject-introspection
    gettext
    itstool
    libxml2
    desktop-file-utils
    blueprint-compiler
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    libgee
    json-glib
    qqwing
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-sudoku"; };
  };

  meta = {
    description = "Test your logic skills in this number grid puzzle";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-sudoku";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-sudoku/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-sudoku";
    teams = [ lib.teams.gnome ];
  };
})

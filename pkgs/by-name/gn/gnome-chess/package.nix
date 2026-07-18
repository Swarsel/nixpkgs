{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk4,
  itstool,
  libadwaita,
  librsvg,
  libxml2,
  meson,
  ninja,
  pango,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-chess";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-chess/${lib.versions.major finalAttrs.version}/gnome-chess-${finalAttrs.version}.tar.xz";
    hash = "sha256-otvnxhO0ZykUF0fii7DLhhTlfeFW07ndpqzosBRqW/w=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gettext
    itstool
    libxml2
    desktop-file-utils
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    librsvg
    pango
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-chess"; };
  };

  meta = {
    description = "Play the classic two-player boardgame of chess";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-chess";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-chess";
    teams = [ lib.teams.gnome ];
  };
})

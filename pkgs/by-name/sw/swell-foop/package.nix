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
  libgee,
  libxml2,
  meson,
  ninja,
  pango,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swell-foop";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/swell-foop/${lib.versions.major finalAttrs.version}/swell-foop-${finalAttrs.version}.tar.xz";
    hash = "sha256-lrJDAj4NSmb5hrwpaLDwuGYY4VpV+X6D/mqwCefngus=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook4
    python3
    itstool
    gettext
    libxml2
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libgee
    pango
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "swell-foop";
    };
  };

  meta = {
    description = "Puzzle game, previously known as Same GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/swell-foop";
    changelog = "https://gitlab.gnome.org/GNOME/swell-foop/-/tree/${finalAttrs.version}?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "swell-foop";
    teams = [ lib.teams.gnome ];
  };
})

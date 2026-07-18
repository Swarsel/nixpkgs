{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  gnome,
  gtk4,
  itstool,
  libadwaita,
  libgee,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-mines";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-mines/${lib.versions.major finalAttrs.version}/gnome-mines-${finalAttrs.version}.tar.xz";
    hash = "sha256-nTpEEi0Er3h8ZKhp75DdVOp1AOW0i+RXxtZNmydz+58=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gettext
    itstool
    libxml2
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    gtk4
    libadwaita
    librsvg
    libgee
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-mines";
    };
  };

  meta = {
    description = "Clear hidden mines from a minefield";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-mines";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-mines";
    teams = [ lib.teams.gnome ];
  };
})

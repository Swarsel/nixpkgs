{
  lib,
  stdenv,
  fetchurl,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gtk3,
  libgnome-games-support,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atomix";
  version = "44.0";

  src = fetchurl {
    url = "mirror://gnome/sources/atomix/${lib.versions.major finalAttrs.version}/atomix-${finalAttrs.version}.tar.xz";
    hash = "sha256-yISTF2iNh9pzTJBjA1YxBSAH8qh5m2xsyRUmWIC1X7Q=";
  };

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    wrapGAppsHook3
    python3
  ];

  buildInputs = [
    glib
    gtk3
    gdk-pixbuf
    libgnome-games-support
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "atomix"; };
  };

  meta = {
    description = "Puzzle game where you move atoms to build a molecule";
    homepage = "https://gitlab.gnome.org/GNOME/atomix";
    changelog = "https://gitlab.gnome.org/GNOME/atomix/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "atomix";
    teams = [ lib.teams.gnome ];
  };
})

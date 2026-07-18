{
  lib,
  stdenv,
  fetchFromGitLab,
  freerdp,
  fuse3,
  glib,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  vala,
}:

stdenv.mkDerivation {
  pname = "gtk-frdp";
  version = "0-unstable-2026-04-24";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gtk-frdp";
    rev = "05919e9958b655252a0e5572c215fc9aee0aa863";
    hash = "sha256-SGSHsuv/XOLfjESRk9B2GV64zvrG8xGoaBoHO6EeAZw=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    freerdp
    fuse3
  ];

  passthru = {
    updateScript = unstableGitUpdater {
      hardcodeZeroVersion = true;
      tagPrefix = "v";
    };
  };

  meta = {
    description = "RDP viewer widget for GTK";
    homepage = "https://gitlab.gnome.org/GNOME/gtk-frdp";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}

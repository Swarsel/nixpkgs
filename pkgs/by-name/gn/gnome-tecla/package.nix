{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnome,
  gtk4,
  libadwaita,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  wayland,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tecla";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/tecla/${lib.versions.major finalAttrs.version}/tecla-${finalAttrs.version}.tar.xz";
    hash = "sha256-JUKsskhQCC4Mz2qhevllHbcdIvDiM/2/XtDP/i5FvAY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libxkbcommon
    wayland
  ];

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gnome-tecla";
      packageName = "tecla";
    };
  };

  meta = {
    description = "Keyboard layout viewer";
    homepage = "https://gitlab.gnome.org/GNOME/tecla";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "tecla";
    teams = [ lib.teams.gnome ];
  };
})

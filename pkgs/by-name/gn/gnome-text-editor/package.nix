{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  editorconfig-core-c,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gtk4,
  gtksourceview5,
  icu,
  itstool,
  libadwaita,
  libspelling,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-text-editor";
  version = "50.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-text-editor/${lib.versions.major finalAttrs.version}/gnome-text-editor-${finalAttrs.version}.tar.xz";
    hash = "sha256-9oA2sJ03j6qIO/6Tbkecb/NwJ8L/7RAdr5Et9wxR0OY=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    itstool
    libxml2 # for xmllint
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
  ];

  buildInputs = [
    icu
    glib
    gsettings-desktop-schemas
    gtk4
    gtksourceview5
    libadwaita
    libspelling
    editorconfig-core-c
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-text-editor";
    };
  };

  meta = {
    description = "Text Editor for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-text-editor";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-text-editor/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-text-editor";
    teams = [ lib.teams.gnome ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  cpio,
  desktop-file-utils,
  gettext,
  glib,
  glibcLocales,
  gnome,
  gtk4,
  itstool,
  json-glib,
  libadwaita,
  libarchive,
  libxml2,
  meson,
  nautilus,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "file-roller";
  version = "44.7";

  src = fetchurl {
    url = "mirror://gnome/sources/file-roller/${lib.versions.major finalAttrs.version}/file-roller-${finalAttrs.version}.tar.xz";
    hash = "sha256-Z8ralqJAnIWfN46C++hosOnACmnmt7iF1ULGTqKhKX0=";
  };

  postPatch = ''
    patchShebangs data/set-mime-type-entry.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    glibcLocales
    itstool
    libxml2
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
  ];

  buildInputs = [
    cpio
    glib
    gtk4
    libadwaita
    json-glib
    libarchive
    nautilus
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "file-roller";
    };
  };

  meta = {
    description = "Archive manager for the GNOME desktop environment";
    homepage = "https://gitlab.gnome.org/GNOME/file-roller";
    changelog = "https://gitlab.gnome.org/GNOME/file-roller/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "file-roller";

    teams = [
      lib.teams.gnome
      lib.teams.pantheon
    ];
  };
})

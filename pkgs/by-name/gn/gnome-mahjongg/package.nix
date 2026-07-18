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
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-mahjongg";
  version = "49.1.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-mahjongg/${lib.versions.major finalAttrs.version}/gnome-mahjongg-${finalAttrs.version}.tar.xz";
    hash = "sha256-6e3TGsJpi42aW+HRHGDUNFCoifh2nMoL7zOVoRpdX9E=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    desktop-file-utils
    pkg-config
    libxml2
    itstool
    gettext
    wrapGAppsHook4
    glib # for glib-compile-schemas
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    librsvg
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-mahjongg";
    };
  };

  meta = {
    description = "Disassemble a pile of tiles by removing matching pairs";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-mahjongg";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-mahjongg/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-mahjongg";
    teams = [ lib.teams.gnome ];
  };
})

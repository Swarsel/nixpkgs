{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gnome,
  gtk4,
  help2man,
  itstool,
  libadwaita,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zenity";
  version = "4.2.2";

  src = fetchurl {
    url = "mirror://gnome/sources/zenity/${lib.versions.majorMinor finalAttrs.version}/zenity-${finalAttrs.version}.tar.xz";
    hash = "sha256-AZGGqZYJbvT8NW4hV3tWc/W6o6KayOPWCLdTNxwYAY0=";
  };

  nativeBuildInputs = [
    help2man
    meson
    ninja
    pkg-config
    gettext
    itstool
    libxml2
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "zenity";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Tool to display dialogs from the commandline and shell scripts";
    homepage = "https://gitlab.gnome.org/GNOME/zenity";
    changelog = "https://gitlab.gnome.org/GNOME/zenity/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "zenity";
    teams = [ lib.teams.gnome ];
  };
})

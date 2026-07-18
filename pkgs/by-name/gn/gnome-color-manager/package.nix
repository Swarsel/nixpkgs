{
  lib,
  stdenv,
  fetchurl,
  colord,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk3,
  itstool,
  lcms2,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-color-manager";
  version = "3.36.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-color-manager/${lib.versions.majorMinor finalAttrs.version}/gnome-color-manager-${finalAttrs.version}.tar.xz";
    hash = "sha256-OQTUKrtOpWbfC4gOgr8Ln4Y4bGkvFbMYRppMe+M6iH8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    glib
    itstool
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk3
    colord
    lcms2
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-color-manager";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Set of graphical utilities for color management to be used in the GNOME desktop";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

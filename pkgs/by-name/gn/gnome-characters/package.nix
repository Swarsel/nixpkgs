{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  gjs,
  glib,
  gnome,
  gnome-desktop,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  libadwaita,
  libunistring,
  meson,
  ninja,
  pango,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-characters";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-characters/${lib.versions.major finalAttrs.version}/gnome-characters-${finalAttrs.version}.tar.xz";
    hash = "sha256-QHBzTdY5swlL5Ge7BVpUYbL8MBzfyf7dy0po9HbtWq0=";
  };

  nativeBuildInputs = [
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    gjs
    glib
    gnome-desktop # for typelib
    gsettings-desktop-schemas
    gtk4
    libunistring
    libadwaita
    pango
  ];

  postFixup = ''
    # Fixes https://github.com/NixOS/nixpkgs/issues/31168
    file="$out/share/org.gnome.Characters/org.gnome.Characters"
    sed -e $"2iimports.package._findEffectiveEntryPointName = () => \'$(basename $file)\' " \
      -i $file
    wrapGApp "$file"
  '';

  dontWrapGApps = true;

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-characters"; };
  };

  meta = {
    description = "Simple utility application to find and insert unusual characters";
    homepage = "https://apps.gnome.org/Characters/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-characters";
    teams = [ lib.teams.gnome ];
  };
})

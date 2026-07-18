{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  docbook-xsl-nons,
  gettext,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  itstool,
  libhandy,
  libuuid,
  libxml2,
  libxslt,
  meson,
  nautilus,
  ninja,
  nixosTests,
  pcre2,
  pkg-config,
  python3,
  vala,
  vte,
  which,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-terminal";
  version = "3.60.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-terminal/${lib.versions.majorMinor finalAttrs.version}/gnome-terminal-${finalAttrs.version}.tar.xz";
    hash = "sha256-uNrz8IVFFyxNKIVzP3IDYasDSepmm5kkXu1K0W7T3ig=";
  };

  postPatch = ''
    patchShebangs \
      data/icons/meson_updateiconcache.py \
      data/meson_desktopfile.py \
      data/meson_metainfofile.py \
      src/meson_compileschemas.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    which
    libxml2
    libxslt
    glib # for glib-compile-schemas
    docbook-xsl-nons
    vala
    desktop-file-utils
    wrapGAppsHook3
    python3
  ];

  buildInputs = [
    glib
    gtk4
    gtk3
    libhandy
    gsettings-desktop-schemas
    vte
    libuuid
    nautilus # For extension
    pcre2
  ];

  passthru = {
    tests = {
      test = nixosTests.terminal-emulators.gnome-terminal;
    };

    updateScript = gnome.updateScript {
      packageName = "gnome-terminal";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "GNOME Terminal Emulator";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-terminal";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-terminal";
    teams = [ lib.teams.gnome ];
  };
})

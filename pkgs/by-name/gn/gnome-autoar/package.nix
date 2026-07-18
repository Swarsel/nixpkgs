{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnome,
  gobject-introspection,
  gtk3,
  libarchive,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-autoar";
  version = "0.4.5";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-autoar/${lib.versions.majorMinor finalAttrs.version}/gnome-autoar-${finalAttrs.version}.tar.xz";
    hash = "sha256-g4xTBvw4v6ovI6viQmL0vxV3HjMD+13LdPW5x6YV2r4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    libarchive
    glib
  ];

  mesonFlags = [
    "-Dvapi=true"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-autoar";
    };
  };

  meta = {
    description = "Library to integrate compressed files management with GNOME";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

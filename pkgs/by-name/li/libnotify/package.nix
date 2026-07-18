{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  docbook-xsl-ns,
  gdk-pixbuf,
  glib,
  gnome,
  gobject-introspection,
  libxslt,
  meson,
  ninja,
  pkg-config,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "libnotify";
  version = "0.8.8";

  src = fetchurl {
    url = "mirror://gnome/sources/libnotify/${lib.versions.majorMinor version}/libnotify-${version}.tar.xz";
    hash = "sha256-I0IO9hncLLWuutYT9II6L6QcB+Wh0FYo1A9uxLNb/d0=";
  };

  outputs = [
    "out"
    "man"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    libxslt
    docbook-xsl-ns
    glib # for glib-mkenums needed during the build
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  propagatedBuildInputs = [
    gdk-pixbuf
    glib
  ];

  mesonFlags = [
    # disable tests as we don't need to depend on GTK 4
    "-Dtests=false"
    "-Ddocbook_docs=disabled"
    "-Dgtk_doc=false"
    "-Dintrospection=${if withIntrospection then "enabled" else "disabled"}"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Library that sends desktop notifications to a notification daemon";
    homepage = "https://gitlab.gnome.org/GNOME/libnotify";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
    mainProgram = "notify-send";
    teams = [ lib.teams.gnome ];
  };
}

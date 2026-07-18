{
  lib,
  stdenv,
  fetchurl,
  blueprint-compiler,
  buildPackages,
  desktop-file-utils,
  docutils,
  gcr_4,
  gdk-pixbuf,
  gettext,
  glib,
  glib-networking,
  gnome,
  gnome-desktop,
  gst_all_1,
  gtk4,
  icu,
  isocodes,
  itstool,
  json-glib,
  libadwaita,
  libarchive,
  libportal-gtk4,
  libsecret,
  libsoup_3,
  libxml2,
  meson,
  nettle,
  ninja,
  p11-kit,
  pantheon,
  pkg-config,
  sqlite,
  webkitgtk_6_0,
  wrapGAppsHook4,
  withPantheon ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "epiphany";
  version = "50.4";

  src = fetchurl {
    url = "mirror://gnome/sources/epiphany/${lib.versions.major finalAttrs.version}/epiphany-${finalAttrs.version}.tar.xz";
    hash = "sha256-Hib5kB8PCL/pQ6pwFjyVMzTH7D1K78jTVOipwUCzNKc=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    docutils # for rst2man
    gettext
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    buildPackages.glib
    buildPackages.gtk4
  ];

  buildInputs = [
    gcr_4
    gdk-pixbuf
    glib
    glib-networking
    gnome-desktop
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gtk4
    icu
    isocodes
    json-glib
    libadwaita
    libportal-gtk4
    libarchive
    libsecret
    libsoup_3
    libxml2
    nettle
    p11-kit
    sqlite
    webkitgtk_6_0
  ]
  ++ lib.optionals withPantheon [
    pantheon.granite7
  ];

  # Tests need an X display
  mesonFlags = [
    "-Dunit_tests=disabled"
  ]
  ++ lib.optionals withPantheon [
    "-Dgranite=enabled"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "epiphany";
    };
  };

  meta = {
    description = "WebKit based web browser for GNOME";
    homepage = "https://apps.gnome.org/Epiphany/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "epiphany";

    teams = [
      lib.teams.gnome
      lib.teams.pantheon
    ];
  };
})

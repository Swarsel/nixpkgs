{
  lib,
  stdenv,
  fetchurl,
  cairo,
  clutter-gtk,
  docbook_xml_dtd_412,
  docbook_xsl,
  glib,
  gnome,
  gobject-introspection, # , libmemphis
  gtk-doc,
  gtk3,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  sqlite,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "libchamplain";
  version = "0.12.21";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "qRXNFyoMUpRMVXn8tGg/ioeMVxv16SglS12v78cn5ac=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals (stdenv.buildPlatform == stdenv.hostPlatform) [ "devdoc" ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
  ]
  ++ lib.optionals (stdenv.buildPlatform == stdenv.hostPlatform) [
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_412
  ];

  buildInputs = [
    sqlite
    libsoup_3
  ];

  propagatedBuildInputs = [
    glib
    gtk3
    cairo
    clutter-gtk
  ];

  mesonFlags = [
    (lib.mesonBool "gtk_doc" (stdenv.buildPlatform == stdenv.hostPlatform))
    "-Dvapi=true"
    (lib.mesonBool "libsoup3" true)
  ];

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libchamplain_libsoup3";
      packageName = "libchamplain";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "C library providing a ClutterActor to display maps";

    longDescription = ''
      libchamplain is a C library providing a ClutterActor to display
       maps.  It also provides a GTK widget to display maps in GTK
       applications.  Python and Perl bindings are also available.  It
       supports numerous free map sources such as OpenStreetMap,
       OpenCycleMap, OpenAerialMap, and Maps for free.
    '';

    homepage = "https://gitlab.gnome.org/GNOME/libchamplain";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;

    teams = [
      lib.teams.gnome
      lib.teams.pantheon
    ];
  };
}

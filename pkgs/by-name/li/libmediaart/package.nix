{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  docbook_xml_dtd_412,
  gdk-pixbuf,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmediaart";
  version = "1.9.7";

  src = fetchurl {
    url = "mirror://gnome/sources/libmediaart/${lib.versions.majorMinor finalAttrs.version}/libmediaart-${finalAttrs.version}.tar.xz";
    sha256 = "K0Pdn1Tw2NC4nirduDNBqwbXuYyxsucEODWEr5xWD2s=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_412
    gobject-introspection
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    gdk-pixbuf
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libmediaart";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Library tasked with managing, extracting and handling media art caches";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})

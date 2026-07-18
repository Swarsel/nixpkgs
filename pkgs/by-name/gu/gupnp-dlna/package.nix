{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  docbook_xml_dtd_412,
  gnome,
  gobject-introspection,
  gst_all_1,
  gtk-doc,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "gupnp-dlna";
  version = "0.12.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-dlna/${lib.versions.majorMinor version}/gupnp-dlna-${version}.tar.xz";
    sha256 = "PVO5b4W8VijTPjZ+yb8q2zjvKzTXrQQ0proM9K2QSOY=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    chmod +x tests/test-discoverer.sh.in
    patchShebangs tests/test-discoverer.sh.in
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_412
  ];

  buildInputs = [
    libxml2
    gst_all_1.gst-plugins-base
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Library to ease DLNA-related bits for applications using GUPnP";
    homepage = "https://gitlab.gnome.org/GNOME/gupnp-dlna";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
  };
}

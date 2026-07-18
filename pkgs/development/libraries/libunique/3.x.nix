{
  lib,
  stdenv,
  fetchurl,
  dbus,
  dbus-glib,
  docbook_xml_dtd_45,
  docbook_xsl,
  gobject-introspection,
  gtk-doc,
  gtk3,
  libxml2,
  libxslt,
  pkg-config,
}:

stdenv.mkDerivation rec {

  pname = "libunique3";
  version = "${majorVer}.${minorVer}";

  src = fetchurl {
    url = "https://ftp.gnome.org/pub/GNOME/sources/libunique/${majorVer}/${srcName}.tar.xz";
    sha256 = "0f70lkw66v9cj72q0iw1s2546r6bwwcd8idcm3621fg2fgh2rw58";
  };

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    dbus
    dbus-glib
    gtk3
    gtk-doc
    docbook_xml_dtd_45
    docbook_xsl
    libxslt
    libxml2
  ];

  majorVer = "3.0";
  minorVer = "2";
  srcName = "libunique-${version}";

  meta = {
    description = "Library for writing single instance applications";
    homepage = "https://gitlab.gnome.org/Archive/unique";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}

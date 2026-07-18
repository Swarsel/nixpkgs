{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gdk-pixbuf,
  gtk-doc,
  libx11,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gdk-pixbuf-xlib";
  version = "2.40.2";

  src = fetchFromGitLab {
    owner = "Archive";
    repo = "gdk-pixbuf-xlib";
    rev = finalAttrs.version;
    hash = "sha256-b4EUaYzg2NlBMU90dGQivOvkv9KKSzES/ymPqzrelu8=";
    domain = "gitlab.gnome.org";
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
    docbook-xsl-nons
    docbook_xml_dtd_43
    gtk-doc
  ];

  propagatedBuildInputs = [
    gdk-pixbuf
    libx11
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  meta = {
    description = "Deprecated API for integrating GdkPixbuf with Xlib data types";
    homepage = "https://gitlab.gnome.org/Archive/gdk-pixbuf-xlib";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})

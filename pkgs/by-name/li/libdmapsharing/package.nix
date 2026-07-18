{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  automake,
  avahi,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gst_all_1,
  gtk-doc,
  libsoup_3,
  libtool,
  pkg-config,
  vala,
  withGtkDoc ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

stdenv.mkDerivation rec {
  pname = "libdmapsharing";
  version = "3.9.13";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "libdmapsharing";
    rev = "${lib.toUpper pname}_${lib.replaceStrings [ "." ] [ "_" ] version}";
    sha256 = "oR9lpOFxgGfrtzncFT6dbmhKQfcuH/NvhOR/USHAHQc=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals withGtkDoc [
    "devdoc"
  ];

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail pkg-config "$PKG_CONFIG"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    gtk-doc # gtkdocize
    pkg-config
    gobject-introspection
    vala
  ]
  ++ lib.optionals withGtkDoc [
    docbook-xsl-nons
    docbook_xml_dtd_43
  ];

  buildInputs = [
    avahi
    gdk-pixbuf
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ]
  ++ lib.optionals withGtkDoc [
    gtk-doc
  ];

  propagatedBuildInputs = [
    glib
    libsoup_3
  ];

  configureFlags = [
    (lib.enableFeature false "tests") # Tests require mDNS server
    (lib.enableFeature withGtkDoc "gtk-doc")
  ];

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  outputBin = "dev";

  meta = {
    description = "Library that implements the DMAP family of protocols";
    homepage = "https://www.flyn.org/projects/libdmapsharing/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
}

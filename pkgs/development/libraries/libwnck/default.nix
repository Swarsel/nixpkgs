{
  lib,
  stdenv,
  fetchurl,
  cairo,
  docbook_xml_dtd_412,
  docbook_xsl,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  libstartup_notification,
  libx11,
  libxi,
  libxres,
  meson,
  mesonEmulatorHook,
  ninja,
  pango,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libwnck";
  version = "43.3";

  src = fetchurl {
    url = "mirror://gnome/sources/libwnck/${lib.versions.major version}/libwnck-${version}.tar.xz";
    sha256 = "avisQajwZ63h08qu0lSoNCO19hrT96Rg/Ky6wuGSvfc=";
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
    gettext
    gobject-introspection
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_412
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    libx11
    libstartup_notification
    pango
    cairo
    libxres
    libxi
  ];

  propagatedBuildInputs = [
    glib
    gtk3
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  outputBin = "dev";

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libwnck";
    };
  };

  meta = {
    description = "Library to manage X windows and workspaces (via pagers, tasklists, etc.)";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ liff ];
    platforms = lib.platforms.linux;
  };
}

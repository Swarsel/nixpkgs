{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  gdk-pixbuf,
  gettext,
  gjs,
  glib,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  itstool,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  python3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  enableWebkit2gtk ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation rec {
  pname = "glade";
  version = "3.40.0";

  src = fetchurl {
    url = "mirror://gnome/sources/glade/${lib.versions.majorMinor version}/glade-${version}.tar.xz";
    sha256 = "McmtrqhJlyq5UXtWThmsGZd8qXdYsQntwxZwCPU+PZw=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace 'webkit2gtk-4.0' 'webkit2gtk-4.1'
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    wrapGAppsHook3
    docbook-xsl-nons
    docbook_xml_dtd_42
    libxslt
    libxml2
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    glib
    gjs
    libxml2
    python3
    python3.pkgs.pygobject3
    gsettings-desktop-schemas
    gdk-pixbuf
    adwaita-icon-theme
  ]
  ++ lib.optionals enableWebkit2gtk [
    webkitgtk_4_1
  ];

  mesonFlags = [
    (lib.mesonEnable "webkit2gtk" enableWebkit2gtk)
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "User interface designer for GTK applications";
    homepage = "https://gitlab.gnome.org/GNOME/glade";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}

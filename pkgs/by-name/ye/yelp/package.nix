{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk4,
  itstool,
  libadwaita,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  sqlite,
  webkitgtk_6_0,
  wrapGAppsHook4,
  xz,
  yelp-xsl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yelp";
  version = "49.1";

  src = fetchurl {
    url = "mirror://gnome/sources/yelp/${lib.versions.major finalAttrs.version}/yelp-${finalAttrs.version}.tar.xz";
    hash = "sha256-Pj6U7y0slIfMUQYuOvv6FXjOvSnYDIQ1e21+5tz9inQ=";
  };

  postPatch = ''
    chmod +x src/link-gnome-help.sh data/domains/gen_yelp_xml.sh
    patchShebangs src/link-gnome-help.sh
    patchShebangs data/domains/gen_yelp_xml.sh
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    bzip2
    glib
    gtk4
    libadwaita
    libxml2
    libxslt
    sqlite
    webkitgtk_6_0
    xz
    yelp-xsl
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "yelp";
    };
  };

  meta = {
    description = "Help viewer for GNOME";
    homepage = "https://apps.gnome.org/Yelp/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

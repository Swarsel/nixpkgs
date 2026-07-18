{
  lib,
  stdenv,
  fetchurl,
  appstream,
  desktop-file-utils,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gettext,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gtk4,
  itstool,
  libadwaita,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  systemd,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-logs";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-logs/${lib.versions.major finalAttrs.version}/gnome-logs-${finalAttrs.version}.tar.xz";
    hash = "sha256-tGbGZgFVUhuoE1M5xt8ICg4HGkb5kRuZFysh+eLf2Ag=";
  };

  nativeBuildInputs = [
    appstream
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gettext
    itstool
    libxml2
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_43
    glib
    gtk4
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    systemd
    gsettings-desktop-schemas
  ];

  mesonFlags = [ "-Dman=true" ];
  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-logs"; };
  };

  meta = {
    description = "Log viewer for the systemd journal";
    homepage = "https://apps.gnome.org/Logs/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-logs";
    teams = [ lib.teams.gnome ];
  };
})

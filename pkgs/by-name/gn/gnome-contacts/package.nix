{
  lib,
  stdenv,
  fetchurl,
  blueprint-compiler,
  desktop-file-utils,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  evolution-data-server-gtk4,
  folks,
  gettext,
  glib,
  gnome,
  gnome-online-accounts,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk4,
  libadwaita,
  libglycin,
  libglycin-gtk4,
  libportal-gtk4,
  libxml2,
  libxslt,
  meson,
  ninja,
  pipewire,
  pkg-config,
  qrencode,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-contacts";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-contacts/${lib.versions.major finalAttrs.version}/gnome-contacts-${finalAttrs.version}.tar.xz";
    hash = "sha256-KjvqNDFxviRPErfCGkDKOOmpLeqYkDk69eisE5vA2rM=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    meson
    ninja
    pkg-config
    vala
    gettext
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-rs # GTK4 sink & paintable
    pipewire # pipewiresrc
    gtk4
    glib
    libportal-gtk4
    evolution-data-server-gtk4
    gsettings-desktop-schemas
    folks
    libadwaita
    libglycin
    libglycin-gtk4
    libxml2
    gnome-online-accounts
    qrencode
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-contacts"; };
  };

  meta = {
    description = "GNOME’s integrated address book";
    homepage = "https://apps.gnome.org/Contacts/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-contacts";
    teams = [ lib.teams.gnome ];
  };
})

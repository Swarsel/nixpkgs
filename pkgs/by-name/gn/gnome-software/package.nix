{
  lib,
  stdenv,
  fetchurl,
  appstream,
  desktop-file-utils,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  docbook_xml_dtd_43,
  flatpak,
  fwupd,
  gettext,
  glib,
  glib-networking,
  gnome,
  gnome-desktop,
  gobject-introspection,
  gsettings-desktop-schemas,
  gspell,
  gst_all_1,
  gtk-doc,
  gtk4,
  isocodes,
  itstool,
  json-glib,
  libadwaita,
  libgudev,
  libsecret,
  libsoup_3,
  libsysprof-capture,
  libxmlb,
  libxslt,
  malcontent,
  meson,
  ninja,
  ostree,
  packagekit,
  pkg-config,
  polkit,
  replaceVars,
  valgrind-light,
  wrapGAppsHook4,
}:

let
  withFwupd = stdenv.hostPlatform.isx86;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-software";
  version = "50.3";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-software/${lib.versions.major finalAttrs.version}/gnome-software-${finalAttrs.version}.tar.xz";
    hash = "sha256-sTGOaPArs5AvzY+QTVbwP1NOpQmPZeTGu5wskk2n+CM=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit isocodes;
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    wrapGAppsHook4
    libxslt
    docbook_xml_dtd_42
    docbook_xml_dtd_43
    valgrind-light
    docbook-xsl-nons
    gtk-doc
    desktop-file-utils
    gobject-introspection
    itstool
  ];

  buildInputs = [
    gtk4
    glib
    glib-networking
    packagekit
    appstream
    libsoup_3
    libadwaita
    gsettings-desktop-schemas
    gnome-desktop
    gspell
    json-glib
    libsecret
    ostree
    polkit
    flatpak
    libgudev
    libxmlb
    malcontent
    libsysprof-capture
    # For video screenshots
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ]
  ++ lib.optionals withFwupd [ fwupd ];

  mesonFlags = [
    # Requires /etc/machine-id, D-Bus system bus, etc.
    "-Dtests=false"
  ]
  ++ lib.optionals (!withFwupd) [ "-Dfwupd=false" ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-software"; };
  };

  meta = {
    description = "Software store that lets you install and update applications and system extensions";
    homepage = "https://apps.gnome.org/Software/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-software";
    teams = [ lib.teams.gnome ];
  };
})

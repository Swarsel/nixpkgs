{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  libgtop,
  libxml2,
  meson,
  networkmanager,
  ninja,
  pkg-config,
  tinysparql,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-usage";
  version = "48.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-usage/${lib.versions.major finalAttrs.version}/gnome-usage-${finalAttrs.version}.tar.xz";
    hash = "sha256-UB3jxtTWU9Wc4NcHdY3M+D3D6oGi7RSS0vMzFi/uChc=";
  };

  postPatch = ''
    chmod +x build-aux/meson/postinstall.sh
    patchShebangs build-aux/meson/postinstall.sh
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    libxml2
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    json-glib
    libadwaita
    libgee
    libgtop
    networkmanager
    tinysparql
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-usage";
    };
  };

  meta = {
    description = "Nice way to view information about use of system resources, like memory and disk space";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-usage";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-usage";
    teams = [ lib.teams.gnome ];
  };
})

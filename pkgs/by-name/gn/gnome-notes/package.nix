{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  curl,
  desktop-file-utils,
  evolution-data-server,
  gettext,
  glib,
  gnome,
  gnome-online-accounts,
  gsettings-desktop-schemas,
  gtk3,
  itstool,
  json-glib,
  libhandy,
  libuuid,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  tinysparql,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-notes";
  version = "40.2";

  src = fetchurl {
    url = "mirror://gnome/sources/bijiben/${lib.versions.major finalAttrs.version}/bijiben-${finalAttrs.version}.tar.xz";
    hash = "sha256-siERvAaVa+81mqzx1u3h5So1sADIgROTZjL4rGztzmc=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    libxml2
    desktop-file-utils
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    json-glib
    libuuid
    curl
    libhandy
    webkitgtk_4_1
    tinysparql
    gnome-online-accounts
    gsettings-desktop-schemas
    evolution-data-server
    adwaita-icon-theme
  ];

  mesonFlags = [ "-Dupdate_mimedb=false" ];
  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gnome-notes";
      packageName = "bijiben";
    };
  };

  meta = {
    description = "Note editor designed to remain simple to use";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-notes";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "bijiben";
    teams = [ lib.teams.gnome ];
  };
})

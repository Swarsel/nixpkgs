{
  lib,
  stdenv,
  fetchurl,
  cairo,
  desktop-file-utils,
  gettext,
  glib,
  gnome,
  gtk3,
  itstool,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hitori";
  version = "44.0";

  src = fetchurl {
    url = "mirror://gnome/sources/hitori/${lib.versions.major finalAttrs.version}/hitori-${finalAttrs.version}.tar.xz";
    hash = "sha256-QicL1PlSXRgNMVG9ckUzXcXPJIqYTgL2j/kw2nmeWDs=";
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
    desktop-file-utils
    libxml2
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    cairo
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "hitori"; };
  };

  meta = {
    description = "GTK application to generate and let you play games of Hitori";
    homepage = "https://gitlab.gnome.org/GNOME/hitori";
    changelog = "https://gitlab.gnome.org/GNOME/hitori/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "hitori";
    teams = [ lib.teams.gnome ];
  };
})

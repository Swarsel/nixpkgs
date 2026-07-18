{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  gettext,
  gnome,
  gtk3,
  itstool,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-tetravex";
  version = "3.38.3";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-tetravex/${lib.versions.majorMinor finalAttrs.version}/gnome-tetravex-${finalAttrs.version}.tar.xz";
    hash = "sha256-g4SawGTUVuHdRrbiAcaGFSYkw9HsS5mTWYWkmqeRcss=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    itstool
    libxml2
    adwaita-icon-theme
    pkg-config
    gettext
    meson
    ninja
    python3
    vala
    desktop-file-utils
  ];

  buildInputs = [ gtk3 ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-tetravex"; };
  };

  meta = {
    description = "Complete the puzzle by matching numbered tiles";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-tetravex";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-tetravex";
    teams = [ lib.teams.gnome ];
  };
})

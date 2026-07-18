{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  gnome,
  gtk3,
  itstool,
  libgnome-games-support,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tali";
  version = "40.9";

  src = fetchurl {
    url = "mirror://gnome/sources/tali/${lib.versions.major finalAttrs.version}/tali-${finalAttrs.version}.tar.xz";
    hash = "sha256-+p7eNm8KcuTKpSGJw6sLEMG1aoDHiFsBZgJVjETc59M=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    python3
    desktop-file-utils
    pkg-config
    adwaita-icon-theme
    libxml2
    itstool
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
    librsvg
    libgnome-games-support
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "tali"; };
  };

  meta = {
    description = "Sort of poker with dice and less money";
    homepage = "https://gitlab.gnome.org/GNOME/tali";
    changelog = "https://gitlab.gnome.org/GNOME/tali/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "tali";
    teams = [ lib.teams.gnome ];
  };
})

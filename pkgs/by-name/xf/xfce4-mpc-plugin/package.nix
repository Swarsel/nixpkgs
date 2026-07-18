{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libmpd,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  xfce4-panel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-mpc-plugin";
  version = "0.6.0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/xfce4-mpc-plugin/${lib.versions.majorMinor finalAttrs.version}/xfce4-mpc-plugin-${finalAttrs.version}.tar.xz";
    hash = "sha256-3uW8wFZrotyVucO0yt1eizuyeYpUoqjYZScIkV/kXVA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libmpd
    libxfce4util
    libxfce4ui
    xfce4-panel
    glib
    gtk3
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-mpc-plugin-";
    url = "https://gitlab.xfce.org/panel-plugins/xfce4-mpc-plugin";
  };

  meta = {
    description = "MPD plugin for Xfce panel";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-mpc-plugin";
    license = lib.licenses.bsd0;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

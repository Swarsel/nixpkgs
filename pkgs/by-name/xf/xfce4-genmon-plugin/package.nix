{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-genmon-plugin";
  version = "4.3.0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/xfce4-genmon-plugin/${lib.versions.majorMinor finalAttrs.version}/xfce4-genmon-plugin-${finalAttrs.version}.tar.xz";
    hash = "sha256-B3GXkR2E5boi57uJXObAONu9jo4AZ+1vTkhQK3FnooI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libxfce4util
    libxfce4ui
    xfce4-panel
    xfconf
    glib
    gtk3
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-genmon-plugin-";
    url = "https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin";
  };

  meta = {
    description = "Generic monitor plugin for the Xfce panel";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

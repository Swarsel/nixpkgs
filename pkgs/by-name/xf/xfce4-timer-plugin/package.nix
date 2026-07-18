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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-timer-plugin";
  version = "1.8.0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/xfce4-timer-plugin/${lib.versions.majorMinor finalAttrs.version}/xfce4-timer-plugin-${finalAttrs.version}.tar.xz";
    hash = "sha256-HTrDqixDRUAMAlZCd452Q6q0EEdiK6+c3AC7rHjon5k=";
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
    glib
    gtk3
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-timer-plugin-";
    url = "https://gitlab.xfce.org/panel-plugins/xfce4-timer-plugin";
  };

  meta = {
    description = "Simple countdown and alarm plugin for the Xfce panel";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-timer-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

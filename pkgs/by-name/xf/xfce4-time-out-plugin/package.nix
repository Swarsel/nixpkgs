{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libx11,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  xfce4-panel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-time-out-plugin";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-time-out-plugin";
    tag = "xfce4-time-out-plugin-${finalAttrs.version}";
    hash = "sha256-hyeqSnynsjAeD67oPjQs0ZeLKreXFMZXmvu38zweqrE=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
    gtk3
    libx11
    libxfce4ui
    libxfce4util
    xfce4-panel
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-time-out-plugin-"; };

  meta = {
    description = "Panel plug-in to take periodical breaks from the computer";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-time-out-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

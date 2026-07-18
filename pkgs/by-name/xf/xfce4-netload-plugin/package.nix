{
  lib,
  stdenv,
  fetchFromGitLab,
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
  pname = "xfce4-netload-plugin";
  version = "1.5.0";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-netload-plugin";
    tag = "xfce4-netload-plugin-${finalAttrs.version}";
    hash = "sha256-iZnfPCOHg0+eo8ubfIsweH2T/DSLeL2Q+giWK/Vkpko=";
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
    libxfce4ui
    libxfce4util
    xfce4-panel
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-netload-plugin-"; };

  meta = {
    description = "Internet load speed plugin for Xfce4 panel";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-netload-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

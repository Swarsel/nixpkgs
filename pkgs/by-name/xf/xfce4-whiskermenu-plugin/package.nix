{
  lib,
  stdenv,
  fetchFromGitLab,
  accountsservice,
  garcon,
  gettext,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  xfce4-exo,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-whiskermenu-plugin";
  version = "2.10.1";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-whiskermenu-plugin";
    tag = "xfce4-whiskermenu-plugin-${finalAttrs.version}";
    hash = "sha256-mSACaLwC7G2NBg7JbK59hwpkaSnQE4nsfSH1oABdOso=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    accountsservice
    xfce4-exo
    garcon
    glib
    gtk-layer-shell
    gtk3
    libxfce4ui
    libxfce4util
    xfce4-panel
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-whiskermenu-plugin-"; };

  meta = {
    description = "Alternate application launcher for Xfce";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-whiskermenu-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-popup-whiskermenu";
    teams = [ lib.teams.xfce ];
  };
})

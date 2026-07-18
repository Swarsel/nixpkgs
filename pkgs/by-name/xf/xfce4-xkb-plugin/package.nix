{
  lib,
  stdenv,
  fetchFromGitLab,
  garcon,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libnotify,
  librsvg,
  libwnck,
  libxfce4ui,
  libxfce4util,
  libxklavier,
  meson,
  ninja,
  pkg-config,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-xkb-plugin";
  version = "0.9.0";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-xkb-plugin";
    tag = "xfce4-xkb-plugin-${finalAttrs.version}";
    hash = "sha256-yLlUKp7X8bylJs7ioQJ36mfqFlsiZXOgFXa0ZP7AG1E=";
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
    garcon
    glib
    gtk3
    libnotify
    librsvg
    libxfce4ui
    libxfce4util
    libxklavier
    libwnck
    xfce4-panel
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-xkb-plugin-"; };

  meta = {
    description = "Allows you to setup and use multiple keyboard layouts";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-xkb-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

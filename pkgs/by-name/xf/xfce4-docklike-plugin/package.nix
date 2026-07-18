{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  gettext,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  libx11,
  libxfce4ui,
  libxfce4util,
  libxfce4windowing,
  libxi,
  meson,
  ninja,
  pkg-config,
  xfce4-panel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-docklike-plugin";
  version = "0.5.1";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-docklike-plugin";
    tag = "xfce4-docklike-plugin-${finalAttrs.version}";
    hash = "sha256-p4uRdxwV8cfRPQ3eGfa4/Wt3Im7hgze3UvK9a7pW94o=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cairo
    glib
    gtk3
    gtk-layer-shell
    libx11
    libxi
    libxfce4ui
    libxfce4util
    libxfce4windowing
    xfce4-panel
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-docklike-plugin-"; };

  meta = {
    description = "Modern, minimalist taskbar for Xfce";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-docklike-plugin/start";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

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
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-battery-plugin";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-battery-plugin";
    tag = "xfce4-battery-plugin-${finalAttrs.version}";
    hash = "sha256-I4x2QRYp6H5mR4J7nQ+VZ/T3r/dj4r4M9JbgN+oZHWQ=";
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
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-battery-plugin-"; };

  meta = {
    description = "Battery plugin for Xfce panel";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-battery-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

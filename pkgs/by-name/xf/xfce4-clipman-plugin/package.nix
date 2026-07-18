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
  libxtst,
  meson,
  ninja,
  pkg-config,
  qrencode,
  wayland,
  wayland-scanner,
  wlr-protocols,
  wrapGAppsHook3,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-clipman-plugin";
  version = "1.7.0";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-clipman-plugin";
    tag = "xfce4-clipman-plugin-${finalAttrs.version}";
    hash = "sha256-w9axHJJnTQrkN9s3RQyvkOcK0FOqsvWpoJ+UCDntnZk=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libx11
    libxtst
    libxfce4ui
    libxfce4util
    qrencode
    xfce4-panel
    xfconf
    wayland
    wlr-protocols
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-clipman-plugin-"; };

  meta = {
    description = "Clipboard manager for Xfce panel";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-clipman-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

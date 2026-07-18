{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  thunar,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar-archive-plugin";
  version = "0.6.0";

  src = fetchFromGitLab {
    owner = "thunar-plugins";
    repo = "thunar-archive-plugin";
    tag = "thunar-archive-plugin-${finalAttrs.version}";
    hash = "sha256-/WLkEqzFAKpB7z8mWSgufo4Qbj6KP3Ax8MWVZxIwDs0=";
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
    thunar
    glib
    gtk3
    libxfce4util
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "thunar-archive-plugin-"; };

  meta = {
    description = "Thunar plugin providing file context menus for archives";
    homepage = "https://gitlab.xfce.org/thunar-plugins/thunar-archive-plugin";
    license = lib.licenses.lgpl2Only;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

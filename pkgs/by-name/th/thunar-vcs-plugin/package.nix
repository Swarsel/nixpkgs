{
  lib,
  stdenv,
  fetchFromGitLab,
  apr,
  aprutil,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  subversion,
  thunar,
  wrapGAppsHook3,
  xfce4-exo,
  withSubversion ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar-vcs-plugin";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "thunar-plugins";
    repo = "thunar-vcs-plugin";
    tag = "thunar-vcs-plugin-${finalAttrs.version}";
    hash = "sha256-VuTTao46/3JNzCHv7phCC8DCy9rjlEcMuGmGiIOSsMM=";
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
    thunar
    xfce4-exo
    libxfce4ui
    libxfce4util
    gtk3
    glib
  ]
  ++ lib.optionals withSubversion [
    apr
    aprutil
    subversion
  ];

  mesonFlags = [
    (lib.mesonEnable "svn" withSubversion)
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "thunar-vcs-plugin-"; };

  meta = {
    description = "Thunar plugin providing support for Subversion and Git";
    homepage = "https://gitlab.xfce.org/thunar-plugins/thunar-vcs-plugin";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ lordmzte ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

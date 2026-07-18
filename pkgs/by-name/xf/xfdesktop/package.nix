{
  lib,
  stdenv,
  fetchFromGitLab,
  garcon,
  gettext,
  gitUpdater,
  gtk-layer-shell,
  gtk3,
  libnotify,
  libxfce4ui,
  libxfce4util,
  libxfce4windowing,
  libyaml,
  pkg-config,
  thunar,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfce4-exo,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfdesktop";
  version = "4.20.2";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfdesktop";
    tag = "xfdesktop-${finalAttrs.version}";
    hash = "sha256-LOsfRB4QVb/r2+uHJf4KvRP9akihbhXq82uSp8I7zlI=";
    domain = "gitlab.xfce.org";
  };

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    xfce4-exo
    gtk3
    libxfce4ui
    libxfce4util
    libxfce4windowing
    libyaml
    xfconf
    libnotify
    garcon
    gtk-layer-shell
    thunar
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfdesktop-";
  };

  meta = {
    description = "Xfce's desktop manager";
    homepage = "https://gitlab.xfce.org/xfce/xfdesktop";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfdesktop";
    teams = [ lib.teams.xfce ];
  };
})

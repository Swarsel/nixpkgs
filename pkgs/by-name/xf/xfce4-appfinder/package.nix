{
  lib,
  stdenv,
  fetchFromGitLab,
  garcon,
  gettext,
  gitUpdater,
  gtk3,
  libxfce4ui,
  libxfce4util,
  pkg-config,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-appfinder";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfce4-appfinder";
    tag = "xfce4-appfinder-${finalAttrs.version}";
    hash = "sha256-HovQnkfv5BOsRPowgMkMEWQmESkivVK0Xb7I15ZaOMc=";
    domain = "gitlab.xfce.org";
  };

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    garcon
    gtk3
    libxfce4ui
    libxfce4util
    xfconf
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfce4-appfinder-";
  };

  meta = {
    description = "Appfinder for the Xfce4 Desktop Environment";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-appfinder";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-appfinder";
    teams = [ lib.teams.xfce ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  gtk3,
  libgudev,
  libxfce4ui,
  libxfce4util,
  pkg-config,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfce4-exo,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar-volman";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "thunar-volman";
    tag = "thunar-volman-${finalAttrs.version}";
    hash = "sha256-XIVs/vRwy3QJQW/U7eLBvGdzplWlhdxn3f1lyTQsmpE=";
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
    libgudev
    libxfce4ui
    libxfce4util
    xfconf
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "thunar-volman-";
  };

  meta = {
    description = "Thunar extension for automatic management of removable drives and media";
    homepage = "https://gitlab.xfce.org/xfce/thunar-volman";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "thunar-volman";
    teams = [ lib.teams.xfce ];
  };
})

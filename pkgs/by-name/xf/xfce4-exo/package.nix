{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook_xsl,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libxfce4ui,
  libxfce4util,
  libxslt,
  perl,
  pkg-config,
  wrapGAppsHook3,
  xfce4-dev-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "exo";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "exo";
    tag = "exo-${finalAttrs.version}";
    hash = "sha256-mlGsFaKy96eEAYgYYqtEI4naq5ZSEe3V7nsWGAEucn0=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    libxslt
    docbook_xsl
    gettext
    perl
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    glib
    libxfce4ui
    libxfce4util
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "exo-";
  };

  meta = {
    description = "Application library for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/exo";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libical,
  libnotify,
  libxfce4ui,
  libxfce4util,
  pkg-config,
  tzdata,
  wrapGAppsHook3,
  xfce4-dev-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "orage";
  version = "4.20.3";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "orage";
    tag = "orage-${finalAttrs.version}";
    hash = "sha256-0C0vuWvYSBMfyHTQBvfx/Olvg1SjEs9vuT8EOE8Ng70=";
    domain = "gitlab.xfce.org";
  };

  postPatch = ''
    substituteInPlace src/parameters.c        --replace-fail "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
    substituteInPlace src/tz_zoneinfo_read.c  --replace-fail "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libical
    libnotify
    libxfce4ui
    libxfce4util
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "orage-";
  };

  meta = {
    description = "Simple calendar application for Xfce";
    homepage = "https://gitlab.xfce.org/apps/orage";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "orage";
    teams = [ lib.teams.xfce ];
  };
})

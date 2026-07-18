{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus-glib,
  gettext,
  gitUpdater,
  gtk3,
  libepoxy,
  librsvg,
  libstartup_notification,
  libwnck,
  libxdamage,
  libxfce4ui,
  libxfce4util,
  libxpresent,
  pkg-config,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfwm4";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfwm4";
    tag = "xfwm4-${finalAttrs.version}";
    hash = "sha256-5UZQrAH0oz+G+7cvXCLDJ4GSXNJcyl4Ap9umb7h0f5Q=";
    domain = "gitlab.xfce.org";
  };

  nativeBuildInputs = [
    gettext
    librsvg # rsvg-convert
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus-glib
    libepoxy
    gtk3
    libxdamage
    libstartup_notification
    libxfce4ui
    libxfce4util
    libwnck
    libxpresent
    xfconf
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfwm4-";
  };

  meta = {
    description = "Window manager for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/xfwm4";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfwm4";
    teams = [ lib.teams.xfce ];
  };
})

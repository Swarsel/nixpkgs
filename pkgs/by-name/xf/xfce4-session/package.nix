{
  lib,
  stdenv,
  fetchFromGitLab,
  bashNonInteractive,
  gettext,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  iceauth,
  libwnck,
  libxfce4ui,
  libxfce4util,
  libxfce4windowing,
  pkg-config,
  polkit,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfce4-exo,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-session";
  version = "4.20.4";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfce4-session";
    tag = "xfce4-session-${finalAttrs.version}";
    hash = "sha256-mL5fOWJtpkpskBQmyYhcVRzGJlzAHsvtcy4j3DceOBE=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
    iceauth
  ];

  buildInputs = [
    bashNonInteractive
    xfce4-exo
    gtk3
    gtk-layer-shell
    glib
    libxfce4ui
    libxfce4util
    libxfce4windowing
    libwnck
    xfconf
    polkit
  ];

  configureFlags = [
    "--enable-maintainer-mode"
    "--with-xsession-prefix=${placeholder "out"}"
    "--with-wayland-session-prefix=${placeholder "out"}"
  ];

  enableParallelBuilding = true;

  passthru = {
    updateScript = gitUpdater {
      odd-unstable = true;
      rev-prefix = "xfce4-session-";
    };

    xinitrc = "${finalAttrs.finalPackage}/etc/xdg/xfce4/xinitrc";
  };

  meta = {
    description = "Session manager for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-session";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-session";
    teams = [ lib.teams.xfce ];
  };
})

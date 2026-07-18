{
  lib,
  stdenv,
  fetchFromGitLab,
  bashNonInteractive,
  colord,
  garcon,
  gettext,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  libnotify,
  libx11,
  libxext,
  libxfce4ui,
  libxfce4util,
  libxklavier,
  libxml2,
  pkg-config,
  upower,
  wayland-scanner,
  wlr-protocols,
  wrapGAppsHook3,
  xapp,
  xf86-input-libinput,
  xfce4-dev-tools,
  xfce4-exo,
  xfconf,
  withColord ? true,
  # Disabled by default on upstream and actually causes issues:
  # https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/222
  withUpower ? false,
  withXrandr ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-settings";
  version = "4.20.4";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfce4-settings";
    tag = "xfce4-settings-${finalAttrs.version}";
    hash = "sha256-EAiu29wctXg0EjdFVJOl+0nh1A0l2E44v+i/o5l/PQ8=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
    wayland-scanner
    wrapGAppsHook3
    libxml2
  ];

  buildInputs = [
    bashNonInteractive
    xfce4-exo
    garcon
    glib
    gtk3
    gtk-layer-shell
    libnotify
    libx11
    libxext
    libxfce4ui
    libxfce4util
    libxklavier
    wlr-protocols
    xapp # org.x.apps.portal
    xf86-input-libinput
    xfconf
  ]
  ++ lib.optionals withUpower [ upower ]
  ++ lib.optionals withColord [ colord ];

  configureFlags = [
    "--enable-sound-settings"
    (lib.enableFeature withXrandr "xrandr")
  ]
  ++ lib.optionals withUpower [ "--enable-upower-glib" ]
  ++ lib.optionals withColord [ "--enable-colord" ];

  depsBuildBuild = [
    pkg-config
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfce4-settings-";
  };

  meta = {
    description = "Settings manager for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-settings";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-settings-manager";
    teams = [ lib.teams.xfce ];
  };
})

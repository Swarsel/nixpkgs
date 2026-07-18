{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  libx11,
  libxext,
  libxfce4ui,
  libxfce4util,
  libxfixes,
  libxtst,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-scanner,
  wlr-protocols,
  wrapGAppsHook3,
  xfce4-exo,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-screenshooter";
  version = "1.11.3";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfce4-screenshooter";
    tag = "xfce4-screenshooter-${finalAttrs.version}";
    hash = "sha256-VN9j5Ieg3MZwhS4mE4LMRbQ5AM9F8O2n5lx/V0Qk0Po=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    xfce4-exo
    gtk3
    gtk-layer-shell
    libx11
    libxext
    libxfixes
    libxtst
    libxfce4ui
    libxfce4util
    wayland
    wlr-protocols
    xfce4-panel
    xfconf
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-screenshooter-"; };

  meta = {
    description = "Screenshot utility for the Xfce desktop";
    homepage = "https://gitlab.xfce.org/apps/xfce4-screenshooter";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-screenshooter";
    teams = [ lib.teams.xfce ];
  };
})

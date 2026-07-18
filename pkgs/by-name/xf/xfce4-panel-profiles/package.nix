{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk3,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.pygobject3
    ps.psutil
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-panel-profiles";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfce4-panel-profiles";
    rev = "xfce4-panel-profiles-${finalAttrs.version}";
    hash = "sha256-4sUNlabWp6WpBlePVFHejq/+TXiJYSQTnZFp5B258Wc=";
    domain = "gitlab.xfce.org";
  };

  nativeBuildInputs = [
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libxfce4ui
    libxfce4util
    pythonEnv
  ];

  mesonFlags = [
    "-Dpython-path=${lib.getExe pythonEnv}"
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-panel-profiles-"; };

  meta = {
    description = "Simple application to manage Xfce panel layouts";
    homepage = "https://docs.xfce.org/apps/xfce4-panel-profiles/start";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-panel-profiles";
    teams = [ lib.teams.xfce ];
  };
})

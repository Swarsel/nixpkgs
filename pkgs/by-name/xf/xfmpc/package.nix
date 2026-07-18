{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libmpd,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfmpc";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfmpc";
    tag = "xfmpc-${finalAttrs.version}";
    hash = "sha256-fYK8JbWFnkzFpgfmSHa6usnlke4G7pxmdSm7kEQsL5M=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
    # Needed both here and in buildInputs for cross compilation to work
    # as they failed to find native vapigen and thus not building the
    # *.vapi files (this should be fixed when these libraries are built
    # with meson).
    libxfce4ui
    libxfce4util
  ];

  buildInputs = [
    gtk3
    glib
    libxfce4ui
    libxfce4util
    libmpd
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfmpc-"; };

  meta = {
    description = "MPD client written in GTK";
    homepage = "https://docs.xfce.org/apps/xfmpc/start";
    changelog = "https://gitlab.xfce.org/apps/xfmpc/-/blob/xfmpc-${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "xfmpc";
    teams = [ lib.teams.xfce ];
  };
})

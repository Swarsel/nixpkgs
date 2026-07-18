{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  glib,
  gtk3,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gigolo";
  version = "0.6.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "gigolo";
    tag = "gigolo-${finalAttrs.version}";
    hash = "sha256-tyFjVvtDE25y6rnmlESdl8s/GdyHGqbn2Dn/ymIIgWs=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    glib
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "gigolo-"; };

  meta = {
    description = "Frontend to easily manage connections to remote filesystems";
    homepage = "https://gitlab.xfce.org/apps/gigolo";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gigolo";
    teams = [ lib.teams.xfce ];
  };
})

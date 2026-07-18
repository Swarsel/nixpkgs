{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-cpufreq-plugin";
  version = "1.3.0";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-cpufreq-plugin";
    tag = "xfce4-cpufreq-plugin-${finalAttrs.version}";
    hash = "sha256-IJ0gOzMs2JBS8KIlD5NHyUOf53PtTytm8J/j+5AEh5E=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
    gtk3
    libxfce4ui
    libxfce4util
    xfce4-panel
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-cpufreq-plugin-"; };

  meta = {
    description = "CPU Freq load plugin for Xfce panel";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-cpufreq-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

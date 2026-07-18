{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  glib,
  gtk3,
  keybinder3,
  libcanberra,
  libnotify,
  libpulseaudio,
  libxfce4ui,
  libxfce4util,
  libxfce4windowing,
  meson,
  ninja,
  pkg-config,
  xfce4-exo,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-pulseaudio-plugin";
  version = "0.5.1";

  src = fetchFromGitLab {
    owner = "panel-plugins";
    repo = "xfce4-pulseaudio-plugin";
    tag = "xfce4-pulseaudio-plugin-${finalAttrs.version}";
    hash = "sha256-068+lp1X2W201zWN15dklsfEy4Hdy3aOEqC/ic5fMNs=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    xfce4-exo
    glib
    gtk3
    keybinder3
    libcanberra
    libnotify
    libpulseaudio
    libxfce4ui
    libxfce4util
    libxfce4windowing
    xfce4-panel
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-pulseaudio-plugin-"; };

  meta = {
    description = "Adjust the audio volume of the PulseAudio sound system";
    homepage = "https://gitlab.xfce.org/panel-plugins/xfce4-pulseaudio-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})

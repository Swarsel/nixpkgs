{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  gtk3,
  keybinder3,
  libnotify,
  libpulseaudio,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-volumed-pulse";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfce4-volumed-pulse";
    tag = "xfce4-volumed-pulse-${finalAttrs.version}";
    hash = "sha256-TdvqvlpNDs9i7IzegqGYTdvy2OVMdQUFvuENNmpkqAY=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libnotify
    libpulseaudio
    keybinder3
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-volumed-pulse-"; };

  meta = {
    description = "Volume keys control daemon for Xfce using pulseaudio";
    homepage = "https://gitlab.xfce.org/apps/xfce4-volumed-pulse";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-volumed-pulse";
    teams = [ lib.teams.xfce ];
  };
})

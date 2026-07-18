{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  gettext,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  libcanberra-gtk3,
  libnotify,
  libwnck,
  libxml2,
  mate-common,
  mate-desktop,
  mate-panel,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-notification-daemon";
  version = "1.28.5";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "mate-notification-daemon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6N6lD63JL9xAtALn9URjYiCEhMZBC9TfIsrdalyY3YY=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
    gettext
    libxml2 # for xmllint
    mate-common # mate-common.m4 macros
    wrapGAppsHook3
  ];

  buildInputs = [
    libcanberra-gtk3
    libnotify
    libwnck
    gtk-layer-shell
    gtk3
    mate-desktop
    mate-panel
  ];

  configureFlags = [ "--enable-in-process" ];
  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-notification-daemon";
  };

  meta = {
    description = "Notification daemon for MATE Desktop";
    homepage = "https://github.com/mate-desktop/mate-notification-daemon";

    license = with lib.licenses; [
      gpl2Plus
      gpl3Plus
    ];

    platforms = lib.platforms.unix;
    mainProgram = "mate-notification-properties";
    teams = [ lib.teams.mate ];
  };
})

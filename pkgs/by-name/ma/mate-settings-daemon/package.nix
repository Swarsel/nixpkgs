{
  lib,
  stdenv,
  fetchurl,
  dconf,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libcanberra-gtk3,
  libmatekbd,
  libmatemixer,
  libnotify,
  libpulseaudio,
  libxklavier,
  mate-desktop,
  nss,
  pkg-config,
  polkit,
  udevCheckHook,
  wrapGAppsHook3,
  pulseaudioSupport ? stdenv.config.pulseaudio or true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-settings-daemon";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-settings-daemon-${finalAttrs.version}.tar.xz";
    sha256 = "TtfNraqkyZ7//AKCuEEXA7t24HLEHEtXmJ+MW0BhGjo=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    gettext
    pkg-config
    wrapGAppsHook3
    udevCheckHook
  ];

  buildInputs = [
    libxklavier
    libcanberra-gtk3
    libnotify
    libmatekbd
    libmatemixer
    nss
    polkit
    gtk3
    dconf
    mate-desktop
  ]
  ++ lib.optional pulseaudioSupport libpulseaudio;

  configureFlags = lib.optional pulseaudioSupport "--enable-pulse";
  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";
  doInstallCheck = true;
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-settings-daemon";
  };

  meta = {
    description = "MATE settings daemon";
    homepage = "https://github.com/mate-desktop/mate-settings-daemon";

    license = with lib.licenses; [
      gpl2Plus
      gpl3Plus
      lgpl2Plus
      mit
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})

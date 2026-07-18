{
  lib,
  stdenv,
  fetchurl,
  dbus-glib,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  gucharmap,
  hicolor-icon-theme,
  itstool,
  libgtop,
  libmateweather,
  libnl,
  libnotify,
  libwnck,
  libxml2,
  mate-desktop,
  mate-panel,
  pkg-config,
  polkit,
  upower,
  wirelesstools,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-applets";
  version = "1.28.1";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-applets-${finalAttrs.version}.tar.xz";
    sha256 = "pZZxQVJ9xbFy0yKmADwjruwlMWD2ULs2QwoG3a76fi4=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    gettext
    itstool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus-glib
    gtk3
    gucharmap
    hicolor-icon-theme
    libgtop
    libmateweather
    libnl
    libnotify
    libwnck
    libxml2
    mate-desktop # for org.mate.lockdown
    mate-panel
    polkit
    upower
    wirelesstools
  ];

  configureFlags = [
    "--enable-suid=no"
    "--enable-in-process"
  ];

  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-applets";
  };

  meta = {
    description = "Applets for use with the MATE panel";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mate-cpufreq-selector";
    teams = [ lib.teams.mate ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  dbus-glib,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  itstool,
  libcanberra-gtk3,
  libnotify,
  libsecret,
  libtool,
  libxml2,
  mate-desktop,
  mate-panel,
  pkg-config,
  polkit,
  upower,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-power-manager";
  version = "1.28.1";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-power-manager-${finalAttrs.version}.tar.xz";
    sha256 = "jr3LdLYH6Ggza6moFGze+Pl7zlNcKwyzv2UMWPce7iE=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    # Fixes polkit popup after `nixos-rebuild switch`.
    substituteInPlace src/gpm-brightness.c \
      --replace-fail 'SBINDIR "/mate-power-backlight-helper' '"/run/current-system/sw/bin/mate-power-backlight-helper'
  '';

  nativeBuildInputs = [
    pkg-config
    gettext
    libtool
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    itstool
    libxml2
    libcanberra-gtk3
    gtk3
    libsecret
    libnotify
    dbus-glib
    upower
    polkit
    mate-desktop
    mate-panel
  ];

  configureFlags = [
    "--enable-applets"
    "--sbindir=$(out)/bin"
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-power-manager";
  };

  meta = {
    description = "MATE Power Manager";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl2Plus
      fdl11Plus
    ];

    maintainers = with lib.maintainers; [ chpatrick ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libnotify,
  libx11,
  libxext,
  libxfce4ui,
  libxfce4util,
  linuxPackages,
  lm_sensors,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  xfce4-panel,
  nvidiaSupport ? lib.meta.availableOn stdenv.hostPlatform linuxPackages.nvidia_x11.settings.libXNVCtrl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-sensors-plugin";
  version = "1.5.0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/xfce4-sensors-plugin/${lib.versions.majorMinor finalAttrs.version}/xfce4-sensors-plugin-${finalAttrs.version}.tar.xz";
    hash = "sha256-hARCuH/d3NhZW9n4Pqi4H3cf4pa7nSq/Dhl54ghyeuk=";
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
    glib
    gtk3
    libx11
    libxext
    libxfce4ui
    libxfce4util
    xfce4-panel
    libnotify
    lm_sensors
  ]
  ++ lib.optionals nvidiaSupport [ linuxPackages.nvidia_x11.settings.libXNVCtrl ];

  mesonFlags = [
    (lib.mesonEnable "xnvctrl" nvidiaSupport)
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-sensors-plugin-";
    url = "https://gitlab.xfce.org/panel-plugins/xfce4-sensors-plugin";
  };

  meta = {
    description = "Panel plug-in for different sensors using acpi, lm_sensors and hddtemp";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-sensors-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "xfce4-sensors";
    teams = [ lib.teams.xfce ];
  };
})

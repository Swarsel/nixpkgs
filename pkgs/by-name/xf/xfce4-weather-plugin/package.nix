{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  json_c,
  libsoup_3,
  libxfce4ui,
  libxfce4util,
  libxml2,
  meson,
  ninja,
  pkg-config,
  upower,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-weather-plugin";
  version = "0.12.0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/xfce4-weather-plugin/${lib.versions.majorMinor finalAttrs.version}/xfce4-weather-plugin-${finalAttrs.version}.tar.xz";
    hash = "sha256-XdkLAywG70tkuBgCMVTvlGOixpSgKQ5X80EilsdUX/Y=";
  };

  patches = [
    # meson-build: Add missing HAVE_UPOWER_GLIB definition
    # https://gitlab.xfce.org/panel-plugins/xfce4-weather-plugin/-/merge_requests/37
    (fetchpatch {
      hash = "sha256-g9AIp1iBcA3AxD1tpnv32PvxxulXYjFvQh3EqD1gmHg=";
      url = "https://gitlab.xfce.org/panel-plugins/xfce4-weather-plugin/-/commit/1d8e5e5dbbc4d53e4b810f9b01a460197cd47b64.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
    gtk3
    json_c
    libxml2
    libsoup_3
    upower
    libxfce4ui
    libxfce4util
    xfce4-panel
    xfconf
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-weather-plugin-";
    url = "https://gitlab.xfce.org/panel-plugins/xfce4-weather-plugin";
  };

  meta = {
    description = "Weather plugin for the Xfce desktop environment";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-weather-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.xfce ];
  };
})

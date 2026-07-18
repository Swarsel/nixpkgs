{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gettext,
  gitUpdater,
  gtk3,
  hicolor-icon-theme,
  itstool,
  libatasmart,
  libnotify,
  libxml2,
  libxslt,
  lm_sensors,
  mate-panel,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-sensors-applet";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-sensors-applet-${finalAttrs.version}.tar.xz";
    sha256 = "1GU2ZoKvj+uGGCg8l4notw22/RfKj6lQrG9xAQIxWoE=";
  };

  patches = [
    # Fix an invalid pointer crash with glib 2.83.2
    # https://github.com/mate-desktop/mate-sensors-applet/pull/137
    (fetchpatch {
      hash = "sha256-PjMc2uEFMljaiKOM5lf6MsdWztZkMfb2Vuxs9tgdaos=";
      url = "https://github.com/mate-desktop/mate-sensors-applet/commit/9b74dc16d852a40d37f7ce6c236406959fd013e5.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    itstool
  ];

  buildInputs = [
    gtk3
    libxml2
    libxslt
    libatasmart
    libnotify
    lm_sensors
    mate-panel
    hicolor-icon-theme
  ];

  configureFlags = [ "--enable-in-process" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-sensors-applet";
  };

  meta = {
    description = "MATE panel applet for hardware sensors";
    homepage = "https://github.com/mate-desktop/mate-sensors-applet";
    license = with lib.licenses; [ gpl2Plus ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.mate ];
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  accountsservice,
  autoconf-archive,
  autoreconfHook,
  caja,
  dbus-glib,
  dconf,
  desktop-file-utils,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  hicolor-icon-theme,
  itstool,
  libayatana-appindicator,
  libcanberra-gtk3,
  libgtop,
  libmatekbd,
  librsvg,
  libxklavier,
  libxml2,
  marco,
  mate-common,
  mate-desktop,
  mate-menus,
  mate-panel,
  mate-settings-daemon,
  pkg-config,
  polkit,
  systemd,
  udisks,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-control-center";
  version = "1.28.1";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "mate-control-center";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rsEu3Ig6GxqPOvAFOXhkEoXM+etyjWpQWHGOsA+myJs=";
  };

  postPatch = ''
    substituteInPlace capplets/system-info/mate-system-info.c \
      --replace-fail "/usr/bin/mate-about" "${mate-desktop}/bin/mate-about"
  '';

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
    gettext
    itstool
    desktop-file-utils
    mate-common # mate-common.m4 macros
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    accountsservice
    libxml2
    dbus-glib
    libxklavier
    libcanberra-gtk3
    libgtop
    libmatekbd
    librsvg
    libayatana-appindicator
    gtk3
    dconf
    polkit
    hicolor-icon-theme
    marco
    mate-desktop
    mate-menus
    mate-panel # for org.mate.panel schema, see m-c-c#678
    mate-settings-daemon
    udisks
    systemd
  ];

  configureFlags = [ "--disable-update-mimedb" ];

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/mate-font-viewer.thumbnailer \
      --replace-fail "TryExec=mate-thumbnail-font" "TryExec=$out/bin/mate-thumbnail-font" \
      --replace-fail "Exec=mate-thumbnail-font" "Exec=$out/bin/mate-thumbnail-font"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # WM keyboard shortcuts
      --prefix XDG_DATA_DIRS : "${marco}/share"
      # Desktop font, works only when passed after gtk3 schemas in the wrapper for some reason
      --prefix XDG_DATA_DIRS : "${glib.getSchemaDataDirPath caja}"
    )
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-control-center";
  };

  meta = {
    description = "Utilities to configure the MATE desktop";
    homepage = "https://github.com/mate-desktop/mate-control-center";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})

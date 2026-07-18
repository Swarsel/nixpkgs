{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus-glib,
  desktop-file-utils,
  glyr,
  gst_all_1,
  gtk3,
  hicolor-icon-theme,
  installShellFiles,
  intltool,
  keybinder3,
  libcddb,
  libcdio,
  libcdio-paranoia,
  libgudev,
  liblastfm-vambrose,
  libmtp,
  libnotify,
  libpeas,
  libsForQt5,
  libxfce4ui,
  pkg-config,
  sqlite,
  taglib,
  totem-pl-parser,
  xfce4-dev-tools,
  zlib,
  withCD ? true,
  withGlyr ? true,
  withGstPlugins ? true,
  withGudev ? false, # experimental
  withKeybinder ? false,
  withLastfm ? true,
  withLibnotify ? false,
  withMtp ? false, # experimental
  withTotemPlParser ? false,
  withXfce4ui ? false,
  # , grilo, withGrilo ? false
  # , rygel, withRygel ? true
}:

assert withGlyr -> withLastfm;
assert withLastfm -> withCD;

stdenv.mkDerivation (finalAttrs: {
  pname = "pragha";
  version = "1.3.99.1";

  src = fetchFromGitHub {
    owner = "pragha-music-player";
    repo = "pragha";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C4zh2NHqP4bwKMi5s+3AfEtKqxRlzL66H8OyNonGzxE=";
  };

  nativeBuildInputs = [
    intltool
    pkg-config
    xfce4-dev-tools
    desktop-file-utils
    installShellFiles
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs =
    with gst_all_1;
    [
      dbus-glib
      gstreamer
      gst-plugins-base
      gtk3
      hicolor-icon-theme
      libpeas
      libsForQt5.qtbase
      sqlite
      taglib
      zlib
    ]
    ++ lib.optionals withGstPlugins [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
    ]
    ++ lib.optionals withCD [
      libcddb
      libcdio
      libcdio-paranoia
    ]
    ++ lib.optional withGudev libgudev
    ++ lib.optional withKeybinder keybinder3
    ++ lib.optional withLibnotify libnotify
    ++ lib.optional withLastfm liblastfm-vambrose
    ++ lib.optional withGlyr glyr
    ++ lib.optional withMtp libmtp
    ++ lib.optional withXfce4ui libxfce4ui
    ++ lib.optional withTotemPlParser totem-pl-parser
  # ++ lib.optional withGrilo grilo
  # ++ lib.optional withRygel rygel
  ;

  env = {
    CFLAGS = toString [ "-DHAVE_PARANOIA_NEW_INCLUDES" ];
    NIX_CFLAGS_COMPILE = "-I${lib.getDev gst_all_1.gst-plugins-base}/include/gstreamer-1.0";
  };

  postInstall = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")

    install -m 444 data/pragha.desktop $out/share/applications
    install -d $out/share/pixmaps
    installManPage data/pragha.1
  '';

  meta = {
    description = "Lightweight GTK+ music manager - fork of Consonance Music Manager";
    homepage = "https://pragha-music-player.github.io/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pragha";
  };
})

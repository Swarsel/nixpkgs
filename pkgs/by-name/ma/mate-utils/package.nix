{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  gettext,
  gitUpdater,
  glib,
  gtk-doc,
  gtk-layer-shell,
  gtk3,
  hicolor-icon-theme,
  inkscape,
  itstool,
  libcanberra-gtk3,
  libgtop,
  libxml2,
  mate-common,
  mate-desktop,
  mate-panel,
  pkg-config,
  udisks,
  wayland,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-utils";
  version = "1.28.1";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "mate-utils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0G25g4vpfufbvUYjCRJVBv9r5t/gnkDzWGKTf8N5MFQ=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    # Workaround undefined version requirements
    # https://github.com/mate-desktop/mate-utils/issues/361
    substituteInPlace configure.ac \
      --replace-fail '>= $GTK_LAYER_SHELL_REQUIRED_VERSION' "" \
      --replace-fail '>= $GDK_WAYLAND_REQUIRED_VERSION' ""

    # Do not build gsearchtool help translations
    # https://github.com/mate-desktop/mate-utils/issues/210
    substituteInPlace gsearchtool/help/Makefile.am \
      --replace 'if USE_NLS' 'if FALSE'
  '';

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
    gettext
    gtk-doc
    itstool
    inkscape
    mate-common # mate-common.m4 macros
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    gtk-layer-shell
    gtk3
    libgtop
    libcanberra-gtk3
    libxml2
    udisks
    mate-desktop
    mate-panel
    hicolor-icon-theme
    wayland
  ];

  configureFlags = [ "--enable-wayland" ];
  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
  };

  meta = {
    description = "Utilities for the MATE desktop";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})

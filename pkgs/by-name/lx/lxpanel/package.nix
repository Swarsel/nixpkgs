{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  cairo,
  curl,
  gdk-pixbuf,
  gdk-pixbuf-xlib,
  gettext,
  gtk2-x11,
  gtk3,
  intltool,
  keybinder,
  keybinder3,
  libfm,
  libwnck,
  libwnck2,
  libx11,
  libxmlxx,
  libxmu,
  libxpm,
  lxmenu-data,
  m4,
  menu-cache,
  pkg-config,
  wirelesstools,
  supportAlsa ? false,
  withGtk3 ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxpanel";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxpanel";
    tag = finalAttrs.version;
    hash = "sha256-jpe5AfRkyTVKQ9biOJiWKv0OVqP8gRCzfhSLDjnrEPc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gettext
    m4
    intltool
    libxmlxx
  ];

  buildInputs = [
    (if withGtk3 then keybinder3 else keybinder)
    (if withGtk3 then gtk3 else gtk2-x11)
    libx11
    (libfm.override { inherit withGtk3; })
    (if withGtk3 then libwnck else libwnck2)
    libxmu
    libxpm
    cairo
    gdk-pixbuf
    gdk-pixbuf-xlib.dev
    menu-cache
    lxmenu-data
    m4
    wirelesstools
    curl
  ]
  ++ lib.optional supportAlsa alsa-lib;

  configureFlags = lib.optional withGtk3 "--enable-gtk3";
  enableParallelBuilding = true;

  meta = {
    description = "Lightweight X11 desktop panel for LXDE";
    homepage = "https://lxde.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.ryneeverett ];
    platforms = lib.platforms.linux;
    mainProgram = "lxpanel";
  };
})

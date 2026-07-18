{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  dbus-glib,
  glib,
  gnome-panel,
  gtk2,
  gtk3,
  libxcb-wm,
  libxfce4util,
  mate-panel,
  pkg-config,
  xfce4-panel,
  desktopSupport ? "gnomeflashback",
}:

assert desktopSupport == "gnomeflashback" || desktopSupport == "mate" || desktopSupport == "xfce4";

stdenv.mkDerivation rec {
  pname = "xmonad-log-applet";
  version = "unstable-2017-09-15";

  src = fetchFromGitHub {
    owner = "kalj";
    repo = "xmonad-log-applet";
    rev = "a1b294cad2f266e4f18d9de34167fa96a0ffdba8";
    sha256 = "042307grf4zvn61gnflhsj5xsjykrk9sjjsprprm4iij0qpybxcw";
  };

  patches = [ ./fix-paths.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    dbus-glib
    libxcb-wm
  ]
  ++ lib.optionals (desktopSupport == "gnomeflashback") [
    gtk3
    gnome-panel
  ]
  ++ lib.optionals (desktopSupport == "mate") [
    gtk3
    mate-panel
  ]
  ++ lib.optionals (desktopSupport == "xfce4") [
    gtk2
    libxfce4util
    xfce4-panel
  ];

  configureFlags = [ "--with-panel=${desktopSupport}" ];
  # Setup hook replaces ${prefix} in pc files so we cannot use
  # --define-variable=prefix=$prefix
  env.PKG_CONFIG_LIBXFCE4PANEL_1_0_LIBDIR = "$(out)/lib";
  name = "xmonad-log-applet-${desktopSupport}-${version}";

  meta = {
    description = "Applet that will display XMonad log information (${desktopSupport} version)";
    homepage = "https://github.com/kalj/xmonad-log-applet";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    broken = desktopSupport == "gnomeflashback" || desktopSupport == "xfce4";
  };
}

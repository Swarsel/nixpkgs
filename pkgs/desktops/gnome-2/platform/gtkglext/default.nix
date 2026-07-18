{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  automake,
  glib,
  gobject-introspection,
  gtk-doc,
  gtk2,
  libGL,
  libGLU,
  libtool,
  libx11,
  libxmu,
  pango,
  pkg-config,
  which,
}:

stdenv.mkDerivation {
  pname = "gtkglext";
  version = "unstable-2019-12-19";

  src = fetchFromGitLab {
    owner = "Archive";
    repo = "gtkglext";
    # build fixes
    # https://gitlab.gnome.org/Archive/gtkglext/merge_requests/1
    rev = "ad95fbab68398f81d7a5c895276903b0695887e2";
    sha256 = "1d1bp4635nla7d07ci40c7w4drkagdqk8wg93hywvdipmjfb4yqb";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    pkg-config
    gtk-doc
    autoconf
    automake
    which
    libtool
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk2
    libGLU
    libGL
    pango
    libx11
    libxmu
  ];

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  meta = {
    description = "GtkGLExt, an OpenGL extension to GTK";

    longDescription = ''
      GtkGLExt is an OpenGL extension to GTK. It provides additional GDK
      objects which support OpenGL rendering in GTK and GtkWidget API
      add-ons to make GTK widgets OpenGL-capable.  In contrast to Janne
      Löf's GtkGLArea, GtkGLExt provides a GtkWidget API that enables
      OpenGL drawing for standard and custom GTK widgets.
    '';

    homepage = "https://projects.gnome.org/gtkglext/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
  };
}

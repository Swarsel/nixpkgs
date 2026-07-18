{
  lib,
  stdenv,
  autoreconfHook,
  dee,
  fetchgit,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  libdbusmenu,
  pkg-config,
  python3,
  vala,
}:

stdenv.mkDerivation {
  pname = "libunity";
  version = "unstable-2021-02-01";

  # Obtained from https://git.launchpad.net/ubuntu/+source/libunity/log/
  src = fetchgit {
    url = "https://git.launchpad.net/ubuntu/+source/libunity";
    rev = "import/7.1.4+19.04.20190319-5";
    sha256 = "LHUs6kl1srS6Xektx+jmm4SXLR47VuQ9IhYbBxf2Wc8=";
  };

  outputs = [
    "out"
    "dev"
    "py"
  ];

  patches = [
    # Fix builf with latest Vala
    # https://code.launchpad.net/~jtojnar/libunity/libunity
    # Did not send upstream because Ubuntu is stuck on Vala 0.48.
    ./fix-vala.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    gobject-introspection
    intltool
    pkg-config
    python3
    vala
  ];

  buildInputs = [
    glib
    gtk3
  ];

  propagatedBuildInputs = [
    dee
    libdbusmenu
  ];

  configureFlags = [
    "--with-pygi-overrides-dir=${placeholder "py"}/${python3.sitePackages}/gi/overrides"
  ];

  preConfigure = ''
    intltoolize
  '';

  meta = {
    description = "Library for instrumenting and integrating with all aspects of the Unity shell";
    homepage = "https://launchpad.net/libunity";
    license = lib.licenses.lgpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}

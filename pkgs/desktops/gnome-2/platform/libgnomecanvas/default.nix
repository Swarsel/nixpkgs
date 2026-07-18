{
  lib,
  stdenv,
  fetchurl,
  glib,
  gtk2,
  intltool,
  libart_lgpl,
  libglade,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libgnomecanvas";
  version = "2.30.3";

  src = fetchurl {
    url = "mirror://gnome/sources/libgnomecanvas/${lib.versions.majorMinor version}/libgnomecanvas-${version}.tar.bz2";
    sha256 = "0h6xvswbqspdifnyh5pm2pqq55yp3kn6yrswq7ay9z49hkh7i6w5";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    intltool
    glib
  ];

  buildInputs = [ libglade ];

  propagatedBuildInputs = [
    libart_lgpl
    gtk2
  ];
}

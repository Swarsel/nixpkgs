{
  lib,
  stdenv,
  fetchurl,
  ORBit2,
  dbus-glib,
  glib,
  intltool,
  libxml2,
  pkg-config,
  polkit,
  python312,
}:

stdenv.mkDerivation rec {
  pname = "gconf";
  version = "3.2.6";

  src = fetchurl {
    url = "mirror://gnome/sources/GConf/${lib.versions.majorMinor version}/GConf-${version}.tar.xz";
    sha256 = "0k3q9nh53yhc9qxf1zaicz4sk8p3kzq4ndjdsgpaa2db0ccbj4hr";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  postPatch = ''
    2to3 --write --nobackup gsettings/gsettings-schema-convert
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    intltool
    python312
    glib
  ];

  buildInputs = [
    ORBit2
    libxml2
  ]
  # polkit requires pam, which requires shadow.h, which is not available on
  # darwin
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) polkit;

  propagatedBuildInputs = [
    glib
    dbus-glib
  ];

  configureFlags =
    # fixes the "libgconfbackend-oldxml.so is not portable" error on darwin
    lib.optionals stdenv.hostPlatform.isDarwin [ "--enable-static" ];

  meta = {
    description = "Deprecated system for storing application preferences";
    homepage = "https://projects.gnome.org/gconf/";
    platforms = lib.platforms.unix;
  };
}

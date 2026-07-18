{
  lib,
  stdenv,
  autoreconfHook,
  cairo,
  fetchpatch2,
  fetchzip,
  glib,
  gnome-common,
  gobject-introspection,
  gtk-doc,
  gtk3,
  libsoup_3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm-gps-map";
  version = "1.2.0";

  src = fetchzip {
    url = "https://github.com/nzjrs/osm-gps-map/releases/download/${finalAttrs.version}/osm-gps-map-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-ciw28YXhR+GC6B2VPC+ZxjyhadOk3zYGuOssSgqjwH0=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  patches = [
    # libsoup 2 is EOL
    # 1. 0001-Drop-support-for-libsoup-older-than-2.42.patch
    (fetchpatch2 {
      hash = "sha256-9KSqXV1ZO21nERlhp0/nZkMuGuMpsr1RfszKkTjyvSo=";
      url = "https://salsa.debian.org/debian-gis-team/osm-gps-map/-/raw/debian/1.2.0-4/debian/patches/0001-Drop-support-for-libsoup-older-than-2.42.patch";
    })
    # 2. port-to-libsoup3.patch
    (fetchpatch2 {
      excludes = [ ".github/*" ];
      hash = "sha256-/Ss/rGm08UXmSpDMNGlS79eQ35sOyU8vAMC9eEBOgKg=";
      url = "https://salsa.debian.org/debian-gis-team/osm-gps-map/-/raw/debian/1.2.0-4/debian/patches/0001-Port-to-libsoup3.patch";
    })
    # 3. fix autoconf checks
    ./port-configure-to-libsoup3.patch

    # libsoup is only used internally
    # it should only be listed as private requirement
    # https://github.com/nzjrs/osm-gps-map/pull/108
    ./dont-require-libsoup.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    pkg-config
    gobject-introspection
    gnome-common
  ];

  buildInputs = [
    cairo
    glib
    libsoup_3
  ];

  propagatedBuildInputs = [
    gtk3
  ];

  configureFlags = [
    "CFLAGS=-std=gnu17"
  ];

  meta = {
    description = "GTK widget for displaying OpenStreetMap tiles";
    homepage = "https://nzjrs.github.io/osm-gps-map";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})

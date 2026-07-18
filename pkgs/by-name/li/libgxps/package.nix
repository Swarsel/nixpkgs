{
  lib,
  stdenv,
  fetchurl,
  cairo,
  freetype,
  glib,
  gnome,
  gobject-introspection,
  lcms2,
  libarchive,
  libjpeg,
  libtiff,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libgxps";
  version = "0.3.2";

  src = fetchurl {
    url = "mirror://gnome/sources/libgxps/${lib.versions.majorMinor version}/libgxps-${version}.tar.xz";
    sha256 = "bSeGclajXM+baSU+sqiKMrrKO5fV9O9/guNmf6Q1JRw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    glib
    cairo
    freetype
    libjpeg
    libtiff
    lcms2
  ];

  propagatedBuildInputs = [ libarchive ];

  mesonFlags = [
    "-Denable-test=false"
  ]
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "-Ddisable-introspection=true"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "GObject based library for handling and rendering XPS documents";
    homepage = "https://gitlab.gnome.org/GNOME/libgxps";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}

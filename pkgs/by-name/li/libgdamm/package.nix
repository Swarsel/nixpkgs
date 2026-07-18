{
  lib,
  stdenv,
  fetchurl,
  glibmm,
  gnome,
  libgda5,
  libxml2,
  pkg-config,
  mysqlSupport ? false,
  postgresSupport ? false,
}:

let
  gda = libgda5.override {
    inherit mysqlSupport postgresSupport;
  };
in
stdenv.mkDerivation rec {
  pname = "libgdamm";
  version = "4.99.11";

  src = fetchurl {
    url = "mirror://gnome/sources/libgdamm/${lib.versions.majorMinor version}/libgdamm-${version}.tar.xz";
    sha256 = "1fyh15b3f8hmwbswalxk1g4l04yvvybksn5nm7gznn5jl5q010p9";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glibmm
    libxml2
  ];

  propagatedBuildInputs = [ gda ];
  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none"; # Should be odd-unstable but stable version has not been released yet.
    };
  };

  meta = {
    description = "C++ bindings for libgda";
    homepage = "https://www.gnome-db.org/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.bot-wxt1221 ];
    platforms = lib.platforms.linux;
  };
}

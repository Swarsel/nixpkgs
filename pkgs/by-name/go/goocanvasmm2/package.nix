{
  lib,
  stdenv,
  fetchurl,
  gnome,
  goocanvas_2,
  gtkmm3,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "goocanvasmm";
  version = "1.90.11";

  src = fetchurl {
    url = "mirror://gnome/sources/goocanvasmm/${lib.versions.majorMinor version}/goocanvasmm-${version}.tar.xz";
    sha256 = "0vpdfrj59nwzwj8bk4s0h05iyql62pxjzsxh72g3vry07s3i3zw0";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    gtkmm3
    goocanvas_2
  ];

  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "goocanvasmm2";
      packageName = pname;
      versionPolicy = "none"; # stable version has not been released yet, last update 2015
    };
  };

  meta = {
    description = "C++ bindings for GooCanvas";
    homepage = "https://gitlab.gnome.org/Archive/goocanvasmm";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}

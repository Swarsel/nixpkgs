{
  lib,
  stdenv,
  fetchurl,
  glibmm,
  gnome,
  libxml2,
  perl,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libxml++";
  version = "2.40.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libxml++/${lib.versions.majorMinor version}/libxml++-${version}.tar.xz";
    sha256 = "1sb3akryklvh2v6m6dihdnbpf1lkx441v972q9hlz1sq6bfspm2a";
  };

  outputs = [
    "out"
    "devdoc"
  ];

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  propagatedBuildInputs = [
    libxml2
    glibmm
  ];

  configureFlags = [
    # remove if library is updated
    "CXXFLAGS=-std=c++11"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libxmlxx";
      freeze = true;
      packageName = "libxml++";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "C++ wrapper for the libxml2 XML parser library";
    homepage = "https://libxmlplusplus.sourceforge.net/";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}

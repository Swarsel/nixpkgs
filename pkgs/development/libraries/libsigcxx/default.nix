{
  lib,
  stdenv,
  fetchurl,
  gnome,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libsigc++";
  version = "2.12.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/${lib.versions.majorMinor version}/libsigc++-${version}.tar.xz";
    sha256 = "sha256-qdvuMjNR0Qm3ruB0qcuJyj57z4rY7e8YUfTPNZvVCEM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libsigcxx";
      freeze = "2.99.1";
      packageName = "libsigc++";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Typesafe callback system for standard C++";
    homepage = "https://libsigcplusplus.github.io/libsigcplusplus/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.all;
  };
}

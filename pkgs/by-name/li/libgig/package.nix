{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  libsndfile,
  libtool,
  libuuid,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libgig";
  version = "4.5.2";

  src = fetchurl {
    url = "https://download.linuxsampler.org/packages/${pname}-${version}.tar.bz2";
    sha256 = "sha256-yivozl4JafkMLfduA9SZ9eJ/tQIe28WH3hgv8n6O/d0=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];

  buildInputs = [
    libsndfile
    libuuid
  ];

  preConfigure = "make -f Makefile.svn";
  enableParallelBuilding = true;

  meta = {
    description = "Gigasampler file access library";
    homepage = "http://www.linuxsampler.org";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}

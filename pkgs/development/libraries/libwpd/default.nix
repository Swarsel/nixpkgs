{
  lib,
  stdenv,
  fetchurl,
  boost,
  glib,
  libgsf,
  librevenge,
  libxml2,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "libwpd";
  version = "0.10.3";

  src = fetchurl {
    url = "mirror://sourceforge/libwpd/libwpd-${version}.tar.xz";
    hash = "sha256-JGWwtmL9xdTjvrzcmnkCdxP7Ypyiv/BKPJJR/exC3Qk=";
  };

  patches = [ ./gcc-1.0.patch ];
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    libgsf
    libxml2
    zlib
    librevenge
    boost
  ];

  meta = {
    description = "Library for importing and exporting WordPerfect documents";
    homepage = "https://libwpd.sourceforge.net/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
  };
}

{
  lib,
  stdenv,
  fetchurl,
  boost,
  cppunit,
  icu,
  lcms2,
  librevenge,
  libwpd,
  libwpg,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcdr";
  version = "0.1.9";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/libcdr-${finalAttrs.version}.tar.xz";
    hash = "sha256-97tqvdfyJoIPKIqT3Y0HdZgzwCUNniAq+Q+bMSxGZaM=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libwpg
    libwpd
    lcms2
    librevenge
    icu
    boost
    cppunit
    zlib
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Library providing ability to interpret and import Corel Draw drawings into various applications";
    homepage = "https://wiki.documentfoundation.org/DLP/Libraries/libcdr";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})

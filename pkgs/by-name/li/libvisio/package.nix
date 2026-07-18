{
  lib,
  stdenv,
  fetchurl,
  boost,
  cppunit,
  doxygen,
  gperf,
  icu,
  librevenge,
  libwpd,
  libwpg,
  libxml2,
  perl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvisio";
  version = "0.1.11";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/libvisio/libvisio-${finalAttrs.version}.tar.xz";
    hash = "sha256-Km79QLbZ28tw+6O+UxEjZogrqXtXFR3zaY36R4yNjdM=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
    "doc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    doxygen
    perl
    gperf
  ];

  buildInputs = [
    boost
    libwpd
    libwpg
    zlib
    librevenge
    libxml2
    icu
    cppunit
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "Library providing ability to interpret and import visio diagrams into various applications";
    homepage = "https://wiki.documentfoundation.org/DLP/Libraries/libvisio";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.unix;
  };
})

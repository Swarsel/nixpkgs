{
  lib,
  stdenv,
  fetchurl,
  boost,
  cppunit,
  doxygen,
  icu,
  libpng,
  librevenge,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzmf";
  version = "0.0.2";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/libzmf/libzmf-${finalAttrs.version}.tar.xz";
    sha256 = "08mg5kmkjrmqrd8j5rkzw9vdqlvibhb1ynp6bmfxnzq5rcq1l197";
  };

  patches = [
    # https://git.libreoffice.org/libzmf/+/48f94abff2fcc4943626a62c6180c60862288b08%5E%21
    ./doxygen.patch
  ];

  nativeBuildInputs = [
    doxygen
    pkg-config
  ];

  buildInputs = [
    boost
    icu
    libpng
    librevenge
    zlib
    cppunit
  ];

  configureFlags = [ "--disable-werror" ];

  meta = {
    description = "Library that parses the file format of Zoner Callisto/Draw documents";
    homepage = "https://wiki.documentfoundation.org/DLP/Libraries/libzmf";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
    downloadPage = "http://dev-www.libreoffice.org/src/libzmf/";
  };
})

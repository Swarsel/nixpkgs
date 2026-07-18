{
  lib,
  stdenv,
  fetchurl,
  boost,
  doxygen,
  gperf,
  librevenge,
  libxml2,
  perl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libabw";
  version = "0.1.4";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/libabw/libabw-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-+iaFo0QNpuA6Zqd4SA2Ty5X2Bk5FQeWONzl2gHYP1qA=";
  };

  # Boost 1.59 compatibility fix
  # Attempt removing when updating
  postPatch = ''
    sed -i 's,^CPPFLAGS.*,\0 -DBOOST_ERROR_CODE_HEADER_ONLY -DBOOST_SYSTEM_NO_DEPRECATED,' src/lib/Makefile.in
  '';

  nativeBuildInputs = [
    doxygen
    gperf
    perl
    pkg-config
  ];

  buildInputs = [
    boost
    librevenge
    libxml2
    zlib
  ];

  meta = {
    description = "Library parsing abiword documents";
    homepage = "https://wiki.documentfoundation.org/DLP/Libraries/libabw";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.unix;
  };
})

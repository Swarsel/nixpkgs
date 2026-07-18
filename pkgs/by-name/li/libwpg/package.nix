{
  lib,
  stdenv,
  fetchurl,
  boost,
  librevenge,
  libwpd,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwpg";
  version = "0.3.4";

  src = fetchurl {
    url = "mirror://sourceforge/libwpg/libwpg-${finalAttrs.version}.tar.xz";
    hash = "sha256-tV/alEDR4HBjDrJIfYuGl89BLCFKJ8runfac7HwATeM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libwpd
    zlib
    librevenge
    boost
  ];

  meta = {
    description = "C++ library to parse WPG";
    homepage = "https://libwpg.sourceforge.net";

    license = with lib.licenses; [
      lgpl21
      mpl20
    ];

    platforms = lib.platforms.all;
  };
})

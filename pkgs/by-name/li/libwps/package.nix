{
  lib,
  stdenv,
  fetchurl,
  boost,
  librevenge,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwps";
  version = "0.4.14";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-xVEdlAngO446F50EZcHMKW7aBvyDcTVu9Egs2oaIadE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    boost
    librevenge
    zlib
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-fallthrough";

  meta = {
    description = "Microsoft Works document format import filter library";
    homepage = "https://libwps.sourceforge.net/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
  };
})

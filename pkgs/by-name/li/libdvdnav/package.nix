{
  lib,
  stdenv,
  fetchurl,
  libdvdread,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdvdnav";
  version = "6.1.1";

  src = fetchurl {
    url = "https://get.videolan.org/libdvdnav/${finalAttrs.version}/libdvdnav-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-wZGnR1lH0yP/doDPksD7G+gjdwGIXzdlbGTQTpjRjUg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libdvdread ];
  passthru = { inherit libdvdread; };

  meta = {
    description = "Library that implements DVD navigation features such as DVD menus";
    homepage = "http://dvdnav.mplayerhq.hu/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.wmertens ];
    platforms = lib.platforms.unix;
  };
})

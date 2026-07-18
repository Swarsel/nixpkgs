{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  withSaidar ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libstatgrab";
  version = "0.92.1";

  src = fetchurl {
    url = "https://ftp.i-scream.org/pub/i-scream/libstatgrab/libstatgrab-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-VoiqSmhVR9cXSoo3PqnY7pJ+dm48wwK97jRSPCxdbBE=";
  };

  buildInputs = lib.optional withSaidar ncurses;

  meta = {
    description = "Library that provides cross platforms access to statistics about the running system";
    homepage = "https://www.i-scream.org/libstatgrab/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})

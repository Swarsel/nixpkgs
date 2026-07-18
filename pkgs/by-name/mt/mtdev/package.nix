{
  lib,
  stdenv,
  fetchurl,
  evdev-proto,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mtdev";
  version = "1.1.7";

  src = fetchurl {
    url = "https://bitmath.org/code/mtdev/mtdev-${finalAttrs.version}.tar.bz2";
    hash = "sha256-oQetrSEB/srFSsf58OCg3RVdlUGT2lXCNAyX8v8dgU4=";
  };

  buildInputs = lib.optional stdenv.hostPlatform.isFreeBSD evdev-proto;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://bitmath.org/git/mtdev.git";
  };

  meta = {
    description = "Multitouch Protocol Translation Library";

    longDescription = ''
      The mtdev is a stand-alone library which transforms all variants of
      kernel MT events to the slotted type B protocol. The events put into
      mtdev may be from any MT device, specifically type A without contact
      tracking, type A with contact tracking, or type B with contact tracking.
      See the kernel documentation for further details.
    '';

    homepage = "https://bitmath.org/code/mtdev/";
    license = lib.licenses.mit;
    platforms = with lib.platforms; freebsd ++ linux;
    mainProgram = "mtdev-test";
  };
})

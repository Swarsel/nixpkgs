{ lib, mkDerivation }:

mkDerivation {
  pname = "libpthread-headers";
  installPhase = "includesPhase";
  dontBuild = true;
  noCC = true;
  path = "lib/libpthread";
  meta.platforms = lib.platforms.netbsd;
}

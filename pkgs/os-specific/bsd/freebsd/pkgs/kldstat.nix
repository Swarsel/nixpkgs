{ lib, mkDerivation }:
mkDerivation {
  path = "sbin/kldstat";
  meta.platforms = lib.platforms.freebsd;
}

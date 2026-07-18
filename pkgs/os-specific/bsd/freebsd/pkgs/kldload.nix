{ lib, mkDerivation }:
mkDerivation {
  path = "sbin/kldload";
  meta.platforms = lib.platforms.freebsd;
}

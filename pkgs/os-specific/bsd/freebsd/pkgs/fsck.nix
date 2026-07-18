{ lib, mkDerivation }:
mkDerivation {
  extraPaths = [ "sbin/mount" ];
  path = "sbin/fsck";
  meta.platforms = lib.platforms.freebsd;
}

{
  lib,
  mkDerivation,
}:
mkDerivation {
  extraPaths = [ "sbin/mount" ];
  path = "sbin/mount_nullfs";
  meta.platforms = lib.platforms.freebsd;
}

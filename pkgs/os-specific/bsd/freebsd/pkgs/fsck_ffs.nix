{
  lib,
  libufs,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [ libufs ];
  extraPaths = [ "sbin/mount" ];
  path = "sbin/fsck_ffs";
  meta.platforms = lib.platforms.freebsd;
}

{
  lib,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  extraPaths = [
    "sbin/mount"
    "usr.sbin/rpc.umntall"
  ];

  path = "sbin/umount";
  meta.platforms = lib.platforms.freebsd;
}

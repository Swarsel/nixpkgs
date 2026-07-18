{ lib, mkDerivation }:
mkDerivation {
  NIX_CFLAGS_COMPILE = [
    "-Wno-unterminated-string-initialization"
  ];

  extraPaths = [
    "sbin/mount"
    "sbin/fsck"
  ];

  path = "sbin/fsck_msdosfs";
  meta.platforms = lib.platforms.freebsd;
}

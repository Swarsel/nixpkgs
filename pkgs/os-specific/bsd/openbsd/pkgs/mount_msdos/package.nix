{
  lib,
  mkDerivation,
}:
mkDerivation {
  extraPaths = [
    "sbin/mount"
  ];

  path = "sbin/mount_msdos";
  meta.mainProgram = "mount_msdos";
  meta.platforms = lib.platforms.openbsd;
}

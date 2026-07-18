{
  lib,
  mkDerivation,
}:

mkDerivation {
  extraPaths = [
    "sbin/mount"
    "sbin/disklabel"
  ];

  path = "sbin/newfs";
  meta.mainProgram = "newfs";
  meta.platforms = lib.platforms.openbsd;
}

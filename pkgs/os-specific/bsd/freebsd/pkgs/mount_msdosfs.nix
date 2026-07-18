{
  lib,
  libkiconv,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [ libkiconv ];
  extraPaths = [ "sbin/mount" ];
  path = "sbin/mount_msdosfs";
  meta.platforms = lib.platforms.freebsd;
}

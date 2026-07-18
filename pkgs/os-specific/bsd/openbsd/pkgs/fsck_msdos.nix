{ mkDerivation }:
mkDerivation {
  extraPaths = [ "sbin/fsck" ];
  path = "sbin/fsck_msdos";
}

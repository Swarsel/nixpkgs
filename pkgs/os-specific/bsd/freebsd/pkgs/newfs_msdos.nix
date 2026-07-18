{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  path = "sbin/newfs_msdos";
}

{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  extraPaths = [ "sys/sys/disk" ];
  path = "usr.bin/mkimg";
}

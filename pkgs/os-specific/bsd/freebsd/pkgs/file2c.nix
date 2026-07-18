{ mkDerivation }:

mkDerivation {
  MK_TESTS = "no";
  path = "usr.bin/file2c";
}

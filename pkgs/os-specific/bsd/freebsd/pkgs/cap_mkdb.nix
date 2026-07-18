{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  path = "usr.bin/cap_mkdb";
}

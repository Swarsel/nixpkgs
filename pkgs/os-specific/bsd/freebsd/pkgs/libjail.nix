{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  path = "lib/libjail";
}

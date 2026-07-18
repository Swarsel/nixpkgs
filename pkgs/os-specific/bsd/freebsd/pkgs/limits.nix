{ libutil, mkDerivation }:
mkDerivation {
  buildInputs = [ libutil ];
  MK_TESTS = "no";
  path = "usr.bin/limits";
}

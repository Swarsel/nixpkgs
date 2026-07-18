{ libgeom, mkDerivation }:
mkDerivation {
  buildInputs = [ libgeom ];
  MK_TESTS = "no";
  path = "sbin/mdconfig";
}

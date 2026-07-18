{ libpam, mkDerivation }:
mkDerivation {
  buildInputs = [ libpam ];
  MK_TESTS = "no";
  extraPaths = [ "contrib/openbsm" ];
  path = "lib/libbsm";
}

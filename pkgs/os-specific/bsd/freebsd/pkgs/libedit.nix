{ libncurses-tinfo, mkDerivation }:
mkDerivation {
  buildInputs = [ libncurses-tinfo ];
  MK_TESTS = "no";
  extraPaths = [ "contrib/libedit" ];
  path = "lib/libedit";
}

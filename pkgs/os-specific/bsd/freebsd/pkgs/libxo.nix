{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  extraPaths = [ "contrib/libxo" ];
  path = "lib/libxo";
}

{ mkDerivation }:
mkDerivation {
  extraPaths = [ "sys" ];
  path = "lib/libkiconv";
}

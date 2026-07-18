{ mkDerivation }:
mkDerivation {
  patches = [ ./no-sbin.patch ];
  path = "bin/chmod";
}

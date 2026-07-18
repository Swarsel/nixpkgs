{ libgeom, mkDerivation }:
mkDerivation {
  buildInputs = [ libgeom ];
  path = "sbin/fdisk";
}

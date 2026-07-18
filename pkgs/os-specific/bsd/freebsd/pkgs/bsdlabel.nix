{ libgeom, mkDerivation }:
mkDerivation {
  buildInputs = [ libgeom ];
  extraPaths = [ "sys/geom" ];
  path = "sbin/bsdlabel";
}

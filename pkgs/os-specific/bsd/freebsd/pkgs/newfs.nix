{ libufs, mkDerivation }:
mkDerivation {
  buildInputs = [ libufs ];
  extraPaths = [ "sys/geom" ];
  path = "sbin/newfs";
}

{ mkDerivation }:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [ ];
  extraPaths = [ "contrib/expat" ];
  path = "lib/libexpat";
}

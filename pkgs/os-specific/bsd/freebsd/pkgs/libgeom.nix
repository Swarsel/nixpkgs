{
  libbsdxml,
  libsbuf,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libbsdxml
    libsbuf
  ];

  makeFlags = [
    "SHLIB_MAJOR=1"
    "STRIP=-s"
  ];

  path = "lib/libgeom";
}

{
  lib,
  cmake,
  extra-cmake-modules,
  kcodecs,
  mkDerivation,
}:

mkDerivation {
  pname = "syndication";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [ kcodecs ];
  meta.maintainers = [ lib.maintainers.bkchr ];
}

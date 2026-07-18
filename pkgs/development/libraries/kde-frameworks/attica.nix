{
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
}:

mkDerivation {
  pname = "attica";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [ qtbase ];
}

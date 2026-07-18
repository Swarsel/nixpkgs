{
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
}:

mkDerivation {
  pname = "threadweaver";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  propagatedBuildInputs = [ qtbase ];
}

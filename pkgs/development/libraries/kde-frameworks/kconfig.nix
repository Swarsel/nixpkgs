{
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "kconfig";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [ qttools ];
  propagatedBuildInputs = [ qtbase ];
}

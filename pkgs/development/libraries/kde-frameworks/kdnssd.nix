{
  avahi,
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "kdnssd";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    avahi
    qttools
  ];

  propagatedBuildInputs = [ qtbase ];
}

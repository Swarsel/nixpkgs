{
  cmake,
  extra-cmake-modules,
  gperf,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "kcodecs";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    qttools
    gperf
  ];

  propagatedBuildInputs = [ qtbase ];
}

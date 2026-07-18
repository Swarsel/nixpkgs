{
  cmake,
  extra-cmake-modules,
  kconfig,
  kwidgetsaddons,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "kcompletion";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    kwidgetsaddons
    qttools
  ];

  propagatedBuildInputs = [ qtbase ];
}

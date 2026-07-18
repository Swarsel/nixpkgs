{
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
  qttools,
  shared-mime-info,
}:

mkDerivation {
  pname = "kcoreaddons";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    qttools
    shared-mime-info
  ];

  propagatedBuildInputs = [ qtbase ];
}

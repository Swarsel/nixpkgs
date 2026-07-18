{
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
  qtgraphicaleffects,
  qtquickcontrols2,
  qttools,
}:

mkDerivation {
  pname = "kirigami2";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    qttools
  ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    qtgraphicaleffects
  ];
}

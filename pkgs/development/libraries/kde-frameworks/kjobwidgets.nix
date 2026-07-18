{
  cmake,
  extra-cmake-modules,
  kcoreaddons,
  kwidgetsaddons,
  mkDerivation,
  qttools,
  qtx11extras,
}:

mkDerivation {
  pname = "kjobwidgets";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    qttools
  ];

  buildInputs = [
    kcoreaddons
    kwidgetsaddons
    qtx11extras
  ];
}

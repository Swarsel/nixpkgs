{
  breeze-icons,
  cmake,
  extra-cmake-modules,
  karchive,
  kconfigwidgets,
  kcoreaddons,
  ki18n,
  kitemviews,
  mkDerivation,
  qtbase,
  qtsvg,
  qttools,
}:

mkDerivation {
  pname = "kiconthemes";

  patches = [
    ./default-theme-breeze.patch
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    breeze-icons
    karchive
    kcoreaddons
    kconfigwidgets
    ki18n
    kitemviews
  ];

  propagatedBuildInputs = [
    qtbase
    qtsvg
    qttools
  ];
}

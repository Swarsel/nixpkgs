{
  cmake,
  extra-cmake-modules,
  kcodecs,
  kconfig,
  kconfigwidgets,
  kcoreaddons,
  kiconthemes,
  kwidgetsaddons,
  kxmlgui,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "kbookmarks";

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
    kcodecs
    kconfig
    kconfigwidgets
    kcoreaddons
    kiconthemes
    kxmlgui
  ];

  propagatedBuildInputs = [
    kwidgetsaddons
    qtbase
  ];
}

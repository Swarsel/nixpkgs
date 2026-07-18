{
  attica,
  cmake,
  extra-cmake-modules,
  kconfig,
  kconfigwidgets,
  kglobalaccel,
  ki18n,
  kiconthemes,
  kitemviews,
  ktextwidgets,
  kwindowsystem,
  mkDerivation,
  qtbase,
  qttools,
  sonnet,
}:

mkDerivation {
  pname = "kxmlgui";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    attica
    kglobalaccel
    ki18n
    kiconthemes
    kitemviews
    ktextwidgets
    kwindowsystem
    sonnet
  ];

  propagatedBuildInputs = [
    kconfig
    kconfigwidgets
    qtbase
    qttools
  ];
}

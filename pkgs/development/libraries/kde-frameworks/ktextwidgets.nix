{
  cmake,
  extra-cmake-modules,
  kcompletion,
  kconfig,
  kconfigwidgets,
  ki18n,
  kiconthemes,
  kservice,
  kwindowsystem,
  mkDerivation,
  qtbase,
  qttools,
  sonnet,
}:

mkDerivation {
  pname = "ktextwidgets";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcompletion
    kconfig
    kconfigwidgets
    kiconthemes
    kservice
    kwindowsystem
  ];

  propagatedBuildInputs = [
    ki18n
    qtbase
    qttools
    sonnet
  ];
}

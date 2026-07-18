{
  attica,
  cmake,
  extra-cmake-modules,
  karchive,
  kcompletion,
  kconfig,
  kcoreaddons,
  ki18n,
  kiconthemes,
  kio,
  kirigami2,
  kitemviews,
  kpackage,
  kservice,
  ktextwidgets,
  kwidgetsaddons,
  kxmlgui,
  mkDerivation,
  qtbase,
  qtdeclarative,
  syndication,
}:

mkDerivation {
  pname = "knewstuff";

  patches = [
    ./0001-Delay-resolving-knsrcdir.patch
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    karchive
    kcompletion
    kconfig
    kcoreaddons
    ki18n
    kiconthemes
    kio
    kitemviews
    kpackage
    ktextwidgets
    kwidgetsaddons
    qtbase
    qtdeclarative
    kirigami2
    syndication
  ];

  propagatedBuildInputs = [
    attica
    kservice
    kxmlgui
  ];
}

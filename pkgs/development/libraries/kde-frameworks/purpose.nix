{
  accounts-qt,
  cmake,
  extra-cmake-modules,
  intltool,
  kconfig,
  kcoreaddons,
  ki18n,
  kio,
  kirigami2,
  mkDerivation,
  qtbase,
  qtdeclarative,
  signond,
}:

mkDerivation {
  pname = "purpose";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    intltool
  ];

  buildInputs = [
    qtbase
    accounts-qt
    qtdeclarative
    kconfig
    kcoreaddons
    ki18n
    kio
    kirigami2
    signond
  ];
}

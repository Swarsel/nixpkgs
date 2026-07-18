{
  boost,
  cmake,
  extra-cmake-modules,
  kconfig,
  kcoreaddons,
  kio,
  kwindowsystem,
  mkDerivation,
  qtbase,
  qtdeclarative,
}:

mkDerivation {
  pname = "kactivities";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    boost
    kconfig
    kcoreaddons
    kio
    kwindowsystem
    qtdeclarative
  ];

  propagatedBuildInputs = [ qtbase ];
}

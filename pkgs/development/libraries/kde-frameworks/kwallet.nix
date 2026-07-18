{
  cmake,
  extra-cmake-modules,
  kconfig,
  kconfigwidgets,
  kcoreaddons,
  kdbusaddons,
  kdoctools,
  ki18n,
  kiconthemes,
  knotifications,
  kservice,
  kwidgetsaddons,
  kwindowsystem,
  libgcrypt,
  mkDerivation,
  qca-qt5,
  qgpgme,
  qtbase,
}:

mkDerivation {
  pname = "kwallet";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
  ];

  buildInputs = [
    kconfig
    kconfigwidgets
    kcoreaddons
    kdbusaddons
    ki18n
    kiconthemes
    knotifications
    kservice
    kwidgetsaddons
    kwindowsystem
    libgcrypt
    qgpgme
    qca-qt5
  ];

  propagatedBuildInputs = [ qtbase ];
}

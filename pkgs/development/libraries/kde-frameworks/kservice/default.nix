{
  bison,
  cmake,
  extra-cmake-modules,
  flex,
  kconfig,
  kcoreaddons,
  kcrash,
  kdbusaddons,
  kdoctools,
  ki18n,
  kwindowsystem,
  mkDerivation,
  qtbase,
  shared-mime-info,
}:

mkDerivation {
  pname = "kservice";

  patches = [
    ./qdiriterator-follow-symlinks.patch
    ./no-canonicalize-path.patch
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
  ];

  buildInputs = [
    kcrash
    kdbusaddons
    ki18n
    kwindowsystem
    qtbase
  ];

  propagatedBuildInputs = [
    kconfig
    kcoreaddons
  ];

  propagatedNativeBuildInputs = [
    bison
    flex
  ];

  propagatedUserEnvPkgs = [ shared-mime-info ]; # for kbuildsycoca5
}

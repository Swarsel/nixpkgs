{
  cmake,
  extra-cmake-modules,
  karchive,
  kconfig,
  kcoreaddons,
  kdoctools,
  ki18n,
  mkDerivation,
  qtbase,
}:

mkDerivation {
  pname = "kpackage";

  patches = [
    ./0001-Allow-external-paths-default.patch
    ./0002-QDirIterator-follow-symlinks.patch
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
  ];

  buildInputs = [
    karchive
    kconfig
    kcoreaddons
    ki18n
    qtbase
  ];
}

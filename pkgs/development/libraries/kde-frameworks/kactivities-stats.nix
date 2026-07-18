{
  lib,
  boost,
  cmake,
  extra-cmake-modules,
  kactivities,
  kconfig,
  mkDerivation,
  qtbase,
}:

mkDerivation {
  pname = "kactivities-stats";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    boost
    kactivities
    kconfig
  ];

  propagatedBuildInputs = [ qtbase ];
  meta.platforms = lib.platforms.linux ++ lib.platforms.freebsd;
}

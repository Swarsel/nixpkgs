{
  cmake,
  extra-cmake-modules,
  kcoreaddons,
  kwindowsystem,
  mkDerivation,
  qtbase,
  qtx11extras,
}:

mkDerivation {
  pname = "kcrash";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcoreaddons
    kwindowsystem
    qtx11extras
  ];

  propagatedBuildInputs = [ qtbase ];
}

{
  cmake,
  extra-cmake-modules,
  kconfig,
  kcoreaddons,
  kcrash,
  kdbusaddons,
  kservice,
  kwindowsystem,
  libxdmcp,
  mkDerivation,
  qtbase,
  qttools,
  qtx11extras,
}:

mkDerivation {
  pname = "kglobalaccel";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    kcrash
    kdbusaddons
    kservice
    kwindowsystem
    qttools
    qtx11extras
    libxdmcp
  ];

  propagatedBuildInputs = [ qtbase ];
}

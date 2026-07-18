{
  cmake,
  extra-cmake-modules,
  libpthread-stubs,
  libxdmcp,
  mkDerivation,
  qtbase,
  qttools,
  qtx11extras,
}:

mkDerivation {
  pname = "kwindowsystem";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    libpthread-stubs
    libxdmcp
    qttools
    qtx11extras
  ];

  propagatedBuildInputs = [ qtbase ];
}

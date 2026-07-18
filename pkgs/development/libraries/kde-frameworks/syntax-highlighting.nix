{
  cmake,
  extra-cmake-modules,
  mkDerivation,
  perl,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "syntax-highlighting";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    perl
  ];

  buildInputs = [ qttools ];
  propagatedBuildInputs = [ qtbase ];
}

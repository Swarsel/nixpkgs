{
  cmake,
  extra-cmake-modules,
  libical,
  mkDerivation,
}:

mkDerivation {
  pname = "kcalendarcore";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  propagatedBuildInputs = [ libical ];
}

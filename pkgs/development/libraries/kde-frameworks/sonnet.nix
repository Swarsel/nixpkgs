{
  aspell,
  cmake,
  extra-cmake-modules,
  hunspell,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "sonnet";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    aspell
    hunspell
    qttools
  ];

  propagatedBuildInputs = [ qtbase ];
}

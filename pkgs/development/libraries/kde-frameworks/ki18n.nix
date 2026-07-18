{
  cmake,
  extra-cmake-modules,
  gettext,
  mkDerivation,
  python3,
  qtdeclarative,
  qtscript,
}:

mkDerivation {
  pname = "ki18n";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    qtdeclarative
    qtscript
  ];

  propagatedNativeBuildInputs = [
    gettext
    python3
  ];
}

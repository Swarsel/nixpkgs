{
  libical,
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kcalendarcore";

  extraBuildInputs = [
    qtdeclarative
    libical
  ];

  hasPythonBindings = true;
}

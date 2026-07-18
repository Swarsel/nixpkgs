{
  hunspell,
  qtModule,
  qtbase,
  qtdeclarative,
  qtsvg,
}:

qtModule {
  pname = "qtvirtualkeyboard";

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
    qtsvg
    hunspell
  ];
}

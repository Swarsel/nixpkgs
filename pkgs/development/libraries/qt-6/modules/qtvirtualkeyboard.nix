{
  hunspell,
  pkg-config,
  qtModule,
  qtbase,
  qtdeclarative,
  qtsvg,
}:

qtModule {
  pname = "qtvirtualkeyboard";
  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
    qtsvg
    hunspell
  ];
}

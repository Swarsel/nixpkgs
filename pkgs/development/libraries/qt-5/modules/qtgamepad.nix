{
  pkg-config,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtgamepad";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

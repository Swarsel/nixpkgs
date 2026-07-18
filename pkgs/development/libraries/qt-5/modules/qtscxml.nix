{
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtscxml";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

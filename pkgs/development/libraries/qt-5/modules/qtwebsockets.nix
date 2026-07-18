{
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtwebsockets";

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

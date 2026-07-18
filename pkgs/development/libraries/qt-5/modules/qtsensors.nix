{
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtsensors";

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

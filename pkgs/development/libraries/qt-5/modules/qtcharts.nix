{
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtcharts";

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

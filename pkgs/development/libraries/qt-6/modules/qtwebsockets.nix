{
  openssl,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtwebsockets";
  buildInputs = [ openssl ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

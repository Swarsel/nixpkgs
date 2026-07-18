{
  openssl,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtquick3d";
  buildInputs = [ openssl ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

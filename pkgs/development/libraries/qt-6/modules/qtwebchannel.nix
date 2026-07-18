{
  openssl,
  qtModule,
  qtbase,
  qtdeclarative,
  qtwebsockets,
}:

qtModule {
  pname = "qtwebchannel";
  buildInputs = [ openssl ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
    qtwebsockets
  ];
}

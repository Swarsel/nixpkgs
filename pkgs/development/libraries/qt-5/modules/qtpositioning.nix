{
  openssl,
  pkg-config,
  qtModule,
  qtbase,
  qtdeclarative,
  qtserialport,
}:

qtModule {
  pname = "qtpositioning";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
    qtserialport
  ];
}

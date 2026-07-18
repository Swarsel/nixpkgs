{
  icu,
  libiconv,
  openssl,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qt5compat";

  buildInputs = [
    libiconv
    icu
    openssl
  ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

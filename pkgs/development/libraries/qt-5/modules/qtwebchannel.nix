{
  lib,
  stdenv,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtwebchannel";

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform) [ "bin" ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

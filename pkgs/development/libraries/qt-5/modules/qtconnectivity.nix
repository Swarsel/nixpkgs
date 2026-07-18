{
  lib,
  stdenv,
  bluez,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtconnectivity";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  buildInputs = lib.optional stdenv.hostPlatform.isLinux bluez;

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

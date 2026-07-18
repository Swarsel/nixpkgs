{
  lib,
  stdenv,
  bluez,
  pcsclite,
  pkg-config,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtconnectivity";
  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    pcsclite
    bluez
  ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}

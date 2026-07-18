{
  lib,
  stdenv,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtdatavis3d";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];

  # error: use of undeclared identifier 'stat64'
  env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64
  ) "-Dstat64=stat";
}

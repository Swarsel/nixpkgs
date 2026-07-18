{
  lib,
  stdenv,
  pkg-config,
  qtModule,
  qtbase,
  udev,
}:

qtModule {
  pname = "qtserialport";
  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ qtbase ] ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ];
}

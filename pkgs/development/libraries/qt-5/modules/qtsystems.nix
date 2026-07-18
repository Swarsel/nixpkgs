{
  lib,
  stdenv,
  bluez,
  libevdev,
  libx11,
  pkg-config,
  qtModule,
  qtbase,
  udev,
  wrapQtAppsHook,
}:

qtModule {
  pname = "qtsystems";

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "bin"
  ];

  nativeBuildInputs = [
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    bluez
    libevdev
    libx11
    udev
  ];

  propagatedBuildInputs = [
    qtbase
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapQtApp $bin/bin/servicefw
  '';

  qmakeFlags = [
    "CONFIG+=git_build"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "CONFIG+=ofono"
    "CONFIG+=udisks"
    "CONFIG+=upower"
  ];

  meta = {
    maintainers = with lib.maintainers; [ OPNA2608 ];
  };
}

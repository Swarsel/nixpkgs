{
  stdenv,
  cmake,
  extra-cmake-modules,
  libsForQt5,
  pkg-config,
  plasma-wayland-protocols,
  sources,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
# not mkKdeDerivation because this is Qt5 land
stdenv.mkDerivation rec {
  inherit (sources.${pname}) version;
  pname = "kwayland-integration";
  src = sources.${pname};

  nativeBuildInputs = [
    cmake
    pkg-config
    extra-cmake-modules
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtwayland

    libsForQt5.__internalKF5.kwayland
    libsForQt5.__internalKF5.kwindowsystem

    plasma-wayland-protocols
    wayland
    wayland-protocols
    wayland-scanner
  ];

  dontWrapQtApps = true;
}

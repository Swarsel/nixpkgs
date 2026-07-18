{
  lib,
  stdenv,
  fetchFromGitHub,
  asio_1_32_0,
  cmake,
  libusb1,
  pkg-config,
  protobuf,
  # Package dependencies
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hidviz";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "hidviz";
    repo = "hidviz";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ThDDQ3FN+cLCbdQCrC5zhL4dgg2zAbRWvtei7+qmQg8=";
  };

  postPatch = ''
    substituteInPlace {hidviz,libhidx{,/libhidx{,_server{,_daemon}}}}/CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 3.2)' 'cmake_minimum_required(VERSION 3.10)'
    substituteInPlace libhidx/cmake_modules/Findasio.cmake --replace-fail '/usr/include/asio' '${lib.getDev asio_1_32_0}/include/asio'
    substituteInPlace libhidx/libhidx/src/Connector.cc --replace-fail '/usr/local/libexec' "$out/libexec"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtwebengine
    libusb1
    protobuf
    # depends on io_service
    asio_1_32_0
  ];

  meta = {
    description = "GUI application for in-depth analysis of USB HID class devices";
    homepage = "https://github.com/hidviz/hidviz";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})

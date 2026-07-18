{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftw,
  libusb1,
  pkg-config,
  rtl-sdr,
}:

stdenv.mkDerivation {
  pname = "dabtools";
  version = "20180405";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "dabtools";
    rev = "8b0b2258b02020d314efd4d0d33a56c8097de0d1";
    sha256 = "18nkdybgg2w6zh56g6xwmg49sifalvraz4rynw8w5d8cqi3dm9sm";
  };

  #  CMake 4 is no longer retro compatible with versions < 3.5
  postPatch = ''
    substituteInPlace CMakeLists.txt src/CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 2.8)" \
      "cmake_minimum_required(VERSION 3.5)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    rtl-sdr
    fftw
    libusb1
  ];

  meta = {
    description = "Commandline tools for DAB and DAB+ digital radio broadcasts";
    homepage = "https://github.com/Opendigitalradio/dabtools";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
  };
}

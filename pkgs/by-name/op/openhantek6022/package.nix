{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftw,
  libglvnd,
  libsForQt5,
  libusb1,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "openhantek6022";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "OpenHantek";
    repo = "OpenHantek6022";
    rev = version;
    sha256 = "sha256-FT+DyfD5WHBblRXWXFnyB2xwoIgoh84oB+QN32wx78c=";
  };

  postPatch = ''
    # Fix up install paths & checks
    sed -i 's#if(EXISTS ".*")#if(1)#g' CMakeLists.txt
    sed -i 's#/lib/udev#lib/udev#g' CMakeLists.txt
    sed -i 's#/usr/share#share#g' CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    fftw
    libusb1
    libglvnd
    libsForQt5.qtbase
    libsForQt5.qttools
  ];

  doInstallCheck = true;

  meta = {
    description = "Free software for Hantek and compatible (Voltcraft/Darkwire/Protek/Acetech) USB digital signal oscilloscopes";
    homepage = "https://github.com/OpenHantek/OpenHantek6022";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ baracoder ];
    platforms = libsForQt5.qtbase.meta.platforms;
    mainProgram = "OpenHantek";
  };
}

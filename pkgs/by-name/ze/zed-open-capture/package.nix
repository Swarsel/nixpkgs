{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hidapi,
  libusb1,
  opencv,
  pkg-config,
  withExamples ? false,
}:

stdenv.mkDerivation {
  pname = "zed-open-capture";
  version = "0.5.0-unstable-2023-24-19";

  src = fetchFromGitHub {
    owner = "stereolabs";
    repo = "zed-open-capture";
    rev = "5cf66ff777175776451b9b59ecc6231d730fa202";
    sha256 = "sha256-ZjgJkCRbvLT7jjOcA8REiEpTg0Jh57du2aMwRk/OKLI=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb1
    hidapi
    opencv
  ];

  # all but one example require opencv with UI support, so disable it.
  # The input OpenCV can be overridden with (opencv.override { enableGtk3 = true; })
  cmakeFlags = lib.optionals (!withExamples) [
    "-DBUILD_EXAMPLES=OFF"
  ];

  meta = {
    description = "Platform-agnostic camera and sensor capture API for the ZED 2, ZED 2i, and ZED Mini stereo cameras";
    homepage = "https://github.com/stereolabs/zed-open-capture";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = lib.platforms.linux;
  };
}

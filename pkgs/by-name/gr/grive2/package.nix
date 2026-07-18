{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  curl,
  expat,
  fetchpatch,
  libgcrypt,
  libiberty,
  pkg-config,
  yajl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grive2";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "vitalif";
    repo = "grive2";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-P6gitA5cXfNbNDy4ohRLyXj/5dUXkCkOdE/9rJPzNCg=";
  };

  patches = [
    # Backport gcc-12 support:
    #   https://github.com/vitalif/grive2/pull/363
    (fetchpatch {
      hash = "sha256-v2Pb6Qvgml/fYzh/VCjOvEVnFYMkOHqROvLLe61DmKA=";
      name = "gcc-12.patch";
      url = "https://github.com/vitalif/grive2/commit/3cf1c058a3e61deb370dde36024a106a213ab2c6.patch";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 2.8)' 'cmake_minimum_required(VERSION 3.10)'

    # boost 1.89 removed the boost_system stub library
    substituteInPlace libgrive/CMakeLists.txt --replace-fail \
      'find_package(Boost 1.40.0 COMPONENTS program_options filesystem unit_test_framework regex system REQUIRED)' \
      'find_package(Boost 1.40.0 COMPONENTS program_options filesystem unit_test_framework regex REQUIRED)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libgcrypt
    yajl
    curl
    expat
    boost
    libiberty
  ];

  meta = {
    description = "Console Google Drive client";
    homepage = "https://github.com/vitalif/grive2";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "grive";
  };
})

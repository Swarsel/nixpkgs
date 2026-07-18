{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  gmp,
  openssl,
  pkg-config,
  procps,
  withProcps ? false,
}:

stdenv.mkDerivation {
  pname = "libsnark";
  version = "20140603-unstable-2024-02-23";

  src = fetchFromGitHub {
    owner = "scipr-lab";
    repo = "libsnark";
    rev = "6c705e3135f585c222813654caedc86520fda1f6";
    hash = "sha256-5Gk24fwVaXBWEFmhTsN9Qm8x/Qpr1KjavI3staJidxQ=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace {,depends/{libff,libfqfft}/}CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace depends/gtest/{,googlemock/,googletest/}CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6.4)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
    boost
    gmp
  ]
  ++ lib.optional withProcps procps;

  cmakeFlags =
    lib.optionals (!withProcps) [ "-DWITH_PROCPS=OFF" ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin || !stdenv.hostPlatform.isx86) [
      "-DWITH_SUPERCOP=OFF"
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isx86) [ "-DCURVE=ALT_BN128" ];

  meta = {
    description = "C++ library for zkSNARKs";
    homepage = "https://github.com/scipr-lab/libsnark";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    broken = withProcps; # Despite procps having a valid pkg-config file, CMake doesn't seem to be able to find it.
  };
}

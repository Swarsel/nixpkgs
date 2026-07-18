{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  tinycmmc,
}:

stdenv.mkDerivation {
  pname = "argpp";
  version = "0-unstable-2022-08-14";

  src = fetchFromGitHub {
    owner = "Grumbel";
    repo = "argpp";
    rev = "9e1d54f8ed20af0aa5857e6653ab605b2ab63d5c";
    sha256 = "sha256-unfAFxgvv1BOUEqrYYMFfouGe2xIcKJ3ithCel1P9sc=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gtest
    tinycmmc
  ];

  meta = {
    description = "Argument Parser for C++";
    homepage = "https://github.com/Grumbel/argpp";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.SchweGELBin ];
    platforms = lib.platforms.linux;
  };
}

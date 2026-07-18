{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation {
  pname = "marl";
  version = "1.0.0"; # Based on marl's CHANGES.md

  src = fetchFromGitHub {
    owner = "google";
    repo = "marl";
    rev = "40209e952f5c1f3bc883d2b7f53b274bd454ca53";
    sha256 = "0pnbarbyv82h05ckays2m3vgxzdhpcpg59bnzsddlb5v7rqhw51w";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];
  # Turn on the flag to install after building the library.
  cmakeFlags = [ "-DMARL_INSTALL=ON" ];

  meta = {
    description = "Hybrid thread / fiber task scheduler written in C++ 11";
    homepage = "https://github.com/google/marl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ breakds ];
    platforms = lib.platforms.all;
  };
}

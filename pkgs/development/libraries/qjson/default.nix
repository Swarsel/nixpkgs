{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qtbase,
}:

stdenv.mkDerivation rec {
  pname = "qjson";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "flavio";
    repo = "qjson";
    rev = version;
    sha256 = "1f4wnxzx0qdmxzc7hqk28m0sva7z9p9xmxm6aifvjlp0ha6pmfxs";
  };

  # CMake 2.8.8 is deprecated and no longer supported by CMake > 4
  # https://github.com/NixOS/nixpkgs/issues/445447
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "CMAKE_MINIMUM_REQUIRED(VERSION 2.8.8)" \
      "CMAKE_MINIMUM_REQUIRED(VERSION 3.10)"
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_policy(SET CMP0020 OLD)" \
      ""
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ qtbase ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-register";
  dontWrapQtApps = true;

  meta = {
    description = "Lightweight data-interchange format";
    homepage = "https://qjson.sourceforge.net/";
    license = lib.licenses.lgpl21;
  };
}

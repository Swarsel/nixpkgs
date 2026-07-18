{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  cmake,
  libGLU,
  libjpeg_turbo,
  libogg,
  libpng,
  libvorbis,
  makeWrapper,
  openal,
  pkg-config,
}:

let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;
in

stdenv.mkDerivation rec {

  pname = "lugaru";
  version = "1.2";

  src = fetchFromGitLab {
    owner = "osslugaru";
    repo = "lugaru";
    rev = version;
    sha256 = "089rblf8xw3c6dq96vnfla6zl8gxcpcbc1bj5jysfpq63hhdpypz";
  };

  # CMake 3.0 is deprecated and no longer supported by CMake > 4
  # https://github.com/NixOS/nixpkgs/issues/445447
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.0)" \
      "cmake_minimum_required(VERSION 3.10)" \
    --replace-fail \
      "cmake_policy(SET CMP0004 OLD)" ""
  '';

  nativeBuildInputs = [
    makeWrapper
    cmake
    pkg-config
  ];

  buildInputs = [
    libGLU
    openal
    SDL2
    libogg
    libvorbis
    libpng
    libjpeg_turbo
  ];

  cmakeFlags = [ "-DSYSTEM_INSTALL=ON" ];

  meta = {
    description = "Third person ninja rabbit fighting game";
    homepage = "https://osslugaru.gitlab.io";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "lugaru";
  };
}

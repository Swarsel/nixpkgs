{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  argpp,
  cmake,
  fmt,
  geomcpp,
  gtest,
  libGL,
  libGLU,
  libpng,
  libsigcxx,
  logmich,
  makeWrapper,
  pkg-config,
  priocpp,
  strutcpp,
  tinycmmc,
  tinygettext,
  uitest,
  wstsound,
  xdgcpp,
}:

stdenv.mkDerivation {
  pname = "pingus";
  version = "0.7.6-unstable-2025-07-21";

  src = fetchFromGitHub {
    owner = "Pingus";
    repo = "pingus";
    rev = "b0ceeeeb95428c73b1b81208211535c61acfc5d0";
    sha256 = "sha256-jQYZM7VLqbl9/+QXyswEXdGmwOq/nxRzWARvcDqNM9M=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libGL
    libGLU
    SDL2
    SDL2_image
    fmt
    gtest
    libpng
    libsigcxx
    argpp
    geomcpp
    logmich
    priocpp
    strutcpp
    tinycmmc
    tinygettext
    uitest
    wstsound
    xdgcpp
  ];

  cmakeFlags = [
    "-DWARNINGS=ON"
    "-DWERROR=ON"
    "-DBUILD_EXTRA=OFF"
    "-DBUILD_TESTS=OFF"
  ];

  doCheck = true;

  meta = {
    description = "Puzzle game with mechanics similar to Lemmings";
    homepage = "https://pingus.seul.org/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      raskin
      SchweGELBin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pingus";
  };
}

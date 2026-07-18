{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  bzip2,
  cmake,
  feather-tk,
  ffmpeg_7,
  freetype,
  glfw,
  imath,
  libGL,
  libjpeg,
  libpng,
  libtiff,
  lunasvg,
  minizip-ng,
  nativefiledialog-extended,
  nlohmann_json,
  opencolorio,
  openexr_2,
  openssl,
  opentimelineio,
  pkg-config,
  plutovg,
  tlrender,
  xz,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "djv";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "grizzlypeak3d";
    repo = "djv";
    tag = finalAttrs.version;
    hash = "sha256-/SakJ23mi/dz8eUt2UtcgfLtFZiCHy1ME+jWdNS8+Fw=";
  };

  postPatch = ''
    substituteInPlace cmake/Modules/djvPackage.cmake \
      --replace-fail \
        ' ''${CMAKE_INSTALL_PREFIX}/etc/tlRender/LICENSE_' \
        " ${tlrender}/etc/tlRender/LICENSE_"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    bzip2
    feather-tk
    ffmpeg_7
    freetype
    glfw
    imath
    tlrender
    libjpeg
    libGL
    libpng
    libtiff
    lunasvg
    minizip-ng
    nativefiledialog-extended
    nlohmann_json
    opencolorio
    openexr_2
    openssl
    opentimelineio
    plutovg
    SDL2
    xz
    zlib
    zstd
  ];

  # GLFW requires a working X11 session.
  doCheck = false;

  meta = {
    description = "Professional review software for VFX, animation, and film production";
    homepage = "https://darbyjohnston.github.io/DJV/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ blitz ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "djv";
  };
})

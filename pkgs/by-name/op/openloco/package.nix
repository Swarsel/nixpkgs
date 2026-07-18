{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  fmt_11,
  libpng,
  libx11,
  libzip,
  openal,
  pkg-config,
  sdl3,
  yaml-cpp,
}:
let
  sfl-src = fetchFromGitHub {
    hash = "sha256-U1InclhSF3pte2AhKUVYBYOXZagksDMkUWgFn5ZB/tk=";
    owner = "slavenf";
    repo = "sfl-library";
    tag = "2.2.0";
  };

  openloco-objects = fetchurl {
    sha256 = "sha256-ZYiR2UpGBAt79x39fwG7wd2mRwcSyz3AdIKTH+tQE8c=";
    url = "https://github.com/OpenLoco/OpenGraphics/releases/download/v0.1.8/objects.zip";
  };

in
stdenv.mkDerivation rec {
  pname = "openloco";
  version = "26.04";

  src = fetchFromGitHub {
    owner = "OpenLoco";
    repo = "OpenLoco";
    tag = "v${version}";
    hash = "sha256-tOvqDJfF6iG05EatUdWGp4wv8UDXdDs1frQ9FMF5myU=";
  };

  postPatch = ''
    # the upstream build process determines the version tag, branch
    # and commit hash from git; since we are not using a git checkout,
    # we patch it manually
    sed -i '/#define OPENLOCO_NAME "OpenLoco"/a\
    #define OPENLOCO_VERSION_TAG "${version}"\
    #define OPENLOCO_BRANCH "master"\
    #define OPENLOCO_COMMIT_SHA1_SHORT "b79ace0"'\
      src/Version/include/OpenLoco/Version.hpp

    # prefetch sfl header sources
    grep -q 'GIT_TAG \+${sfl-src.tag}' thirdparty/CMakeLists.txt
    sed -i 's#GIT_REPOSITORY \+https://github.com/slavenf/sfl-library#SOURCE_DIR ${sfl-src}#' thirdparty/CMakeLists.txt

    # prefetch openloco-objects
    sed -i 's#URL \+${openloco-objects.url}#URL ${openloco-objects}#' CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    sdl3
    libpng
    libzip
    openal
    yaml-cpp
    fmt_11
    libx11
  ];

  cmakeFlags = [
    "-DOPENLOCO_BUILD_TESTS=NO"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=null-dereference";

  meta = {
    description = "Open source re-implementation of Chris Sawyer's Locomotion";
    homepage = "https://github.com/OpenLoco/OpenLoco";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ icewind1991 ];
    platforms = lib.platforms.linux;
    mainProgram = "OpenLoco";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  freetype,
  libjpeg,
  libtiff,
  libxml2,
  opencv,
  openexr,
  pkg-config,
  python3,
  swig,
  zlib,
  withPython ? true,
}:

stdenv.mkDerivation {
  pname = "libyafaray";
  version = "unstable-2022-09-17";

  src = fetchFromGitHub {
    owner = "YafaRay";
    repo = "libYafaRay";
    rev = "6e8c45fb150185b3356220e5f99478f20408ee49";
    sha256 = "sha256-UVBA1vXOuLg4RT+BdF4rhbZ6I9ySeZX0N81gh3MH84I=";
  };

  postPatch = ''
    sed '1i#include <memory>' -i \
      include/geometry/poly_double.h include/noise/noise_generator.h # gcc12
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    freetype
    libjpeg
    libtiff
    libxml2
    opencv
    openexr
    swig
    zlib
  ]
  ++ lib.optional withPython python3;

  meta = {
    description = "Free, open source raytracer";
    homepage = "http://www.yafaray.org";
    license = lib.licenses.lgpl21;
    maintainers = [ ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    downloadPage = "https://github.com/YafaRay/libYafaRay";
  };
}

# TODO: Add optional Ruby support
# TODO: Add Qt support? (CMake looks for it, but what for?)

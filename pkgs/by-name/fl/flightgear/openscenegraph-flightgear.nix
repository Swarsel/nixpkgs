{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitLab,
  boost,
  cmake,
  curl,
  doxygen,
  fetchpatch,
  freetype,
  giflib,
  glib,
  libGL,
  libGLU,
  libjpeg,
  libpng,
  libtiff,
  libx11,
  libxinerama,
  libxml2,
  libxrandr,
  pcre,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation {
  pname = "openscenegraph";
  version = "2024-build";

  src = fetchFromGitLab {
    owner = "flightgear";
    repo = "openscenegraph";
    rev = "b5895abe0d94a57839929d38b5681dc8e796a8a0";
    hash = "sha256-FaTn+QZa1qAU9DNhBjQvBLu/Z9q2liatBbsxY8a0hUI=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-VR8YKOV/YihB5eEGZOGaIfJNrig1EPS/PJmpKsK284c=";
      name = "opencascade-api-patch";
      url = "https://github.com/openscenegraph/OpenSceneGraph/commit/bc2daf9b3239c42d7e51ecd7947d31a92a7dc82b.patch";
    })
    # Fix compiling with libtiff when libtiff is compiled using CMake
    (fetchurl {
      hash = "sha256-YGG/DIHU1f6StbeerZoZrNDm348wYB3ydmVIIGTM7fU=";
      url = "https://github.com/openscenegraph/OpenSceneGraph/commit/9da8d428f6666427c167b951b03edd21708e1f43.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    doxygen
  ];

  buildInputs =
    lib.optionals (!stdenv.hostPlatform.isDarwin) [
      libx11
      libxinerama
      libxrandr
      libGLU
      libGL
    ]
    ++ [
      glib
      libxml2
      pcre
      zlib
      libjpeg
      giflib
      libtiff
      libpng
      curl
      freetype
      boost
    ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_OSG_APPLICATIONS" false)
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin (lib.cmakeFeature "OSG_WINDOWING_SYSTEM" "Cocoa");

  meta = {
    description = "3D graphics toolkit (FlightGear fork)";
    homepage = "https://gitlab.com/flightgear/openscenegraph";
    changelog = "https://gitlab.com/flightgear/openscenegraph/-/commits/release/2024-build";

    # This is a fork of openscenegraph, mirrored licenses
    license = with lib.licenses; [
      lgpl21Only
      wxWindowsException31
    ];

    maintainers = with lib.maintainers; [
      aanderse
      raskin
    ];

    platforms = with lib.platforms; linux ++ darwin;
  };
}

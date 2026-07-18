{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  asio,
  boost,
  cmake,
  collada-dom,
  curl,
  doxygen,
  fetchpatch,
  ffmpeg,
  fltk,
  freetype,
  gdal,
  giflib,
  glib,
  libGL,
  libGLU,
  libjpeg,
  liblas,
  libpng,
  librsvg,
  libtiff,
  libvncserver,
  libx11,
  libxinerama,
  libxml2,
  libxrandr,
  lua,
  nvidia-texture-tools,
  opencascade-occt,
  openexr,
  pcre,
  pkg-config,
  poppler,
  zlib,
  colladaSupport ? false,
  curlSupport ? true,
  exrSupport ? false,
  ffmpegSupport ? false,
  freetypeSupport ? true,
  gdalSupport ? false,
  gifSupport ? true,
  jpegSupport ? true,
  lasSupport ? false,
  luaSupport ? false,
  nvttSupport ? false,
  opencascadeSupport ? false,
  pdfSupport ? false,
  pngSupport ? true,
  restSupport ? false,
  sdlSupport ? false,
  svgSupport ? false,
  tiffSupport ? true,
  vncSupport ? false,
  withApps ? false,
  withExamples ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openscenegraph";
  version = "3.6.5";

  src = fetchFromGitHub {
    owner = "openscenegraph";
    repo = "OpenSceneGraph";
    rev = "OpenSceneGraph-${finalAttrs.version}";
    sha256 = "00i14h82qg3xzcyd8p02wrarnmby3aiwmz0z43l50byc9f8i05n1";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-VR8YKOV/YihB5eEGZOGaIfJNrig1EPS/PJmpKsK284c=";
      name = "opencascade-api-patch";
      url = "https://github.com/openscenegraph/OpenSceneGraph/commit/bc2daf9b3239c42d7e51ecd7947d31a92a7dc82b.patch";
    })
    # OpenEXR 3 support: https://github.com/openscenegraph/OpenSceneGraph/issues/1075
    (fetchurl {
      hash = "sha256-fdNbkg6Vp7DeDBTe5Zso8qJ5v9uPSXHpQ5XlGkvputk=";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-games/openscenegraph/files/openscenegraph-3.6.5-openexr3.patch?id=0f642d8f09b589166f0e0c0fc84df7673990bf3f";
    })
    # Fix compiling with libtiff when libtiff is compiled using CMake
    (fetchurl {
      hash = "sha256-YGG/DIHU1f6StbeerZoZrNDm348wYB3ydmVIIGTM7fU=";
      url = "https://github.com/openscenegraph/OpenSceneGraph/commit/9da8d428f6666427c167b951b03edd21708e1f43.patch";
    })
  ];

  # ref. https://github.com/openscenegraph/OpenSceneGraph/pull/1373
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0 FATAL_ERROR)" \
      "CMAKE_MINIMUM_REQUIRED(VERSION 3.10)"
  '';

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
      zlib
    ]
    ++ lib.optional jpegSupport libjpeg
    ++ lib.optional exrSupport openexr
    ++ lib.optional gifSupport giflib
    ++ lib.optional pngSupport libpng
    ++ lib.optional tiffSupport libtiff
    ++ lib.optional gdalSupport gdal
    ++ lib.optional curlSupport curl
    ++ lib.optionals colladaSupport [
      collada-dom
      pcre
    ]
    ++ lib.optional opencascadeSupport opencascade-occt
    ++ lib.optional ffmpegSupport ffmpeg
    ++ lib.optional nvttSupport nvidia-texture-tools
    ++ lib.optional freetypeSupport freetype
    ++ lib.optional svgSupport librsvg
    ++ lib.optional pdfSupport poppler
    ++ lib.optional vncSupport libvncserver
    ++ lib.optional lasSupport liblas
    ++ lib.optional luaSupport lua
    ++ lib.optional sdlSupport SDL2
    ++ lib.optional restSupport asio
    ++ lib.optionals withExamples [ fltk ]
    ++ lib.optional (restSupport || colladaSupport) boost;

  cmakeFlags =
    lib.optional (!withApps) "-DBUILD_OSG_APPLICATIONS=OFF"
    ++ lib.optional withExamples "-DBUILD_OSG_EXAMPLES=ON";

  env = lib.optionalAttrs colladaSupport { COLLADA_DIR = collada-dom; };

  meta = {
    description = "3D graphics toolkit";
    homepage = "http://www.openscenegraph.org/";

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
})

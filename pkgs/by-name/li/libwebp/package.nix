{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  # for passthru.tests
  gd,
  giflib, # GIF image format
  graphicsmagick,
  haskellPackages,
  imagemagick,
  imlib2,
  libGL,
  libGLU, # OpenGL (required for vwebp)
  libglut,
  libjpeg, # JPEG image format
  libjxl,
  libpng, # PNG image format
  libtiff, # TIFF image format
  libwebp,
  opencv,
  python3,
  testers,
  vips,
  gifSupport ? true,
  jpegSupport ? true,
  libwebpmuxSupport ? true, # Build libwebpmux
  openglSupport ? false,
  pngSupport ? true,
  swap16bitcspSupport ? false, # Byte swap for 16bit color spaces
  threadingSupport ? true, # multi-threading
  tiffSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwebp";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "webmproject";
    repo = "libwebp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7i4fGBTsTjAkBzCjVqXqX4n22j6dLgF/0mz4ajNA45U=";
  };

  patches = [
    # Fixes endianness-related behaviour in build result when targeting big-endian via CMake
    # https://groups.google.com/a/webmproject.org/g/webp-discuss/c/wvBsO8n8BKA/m/eKpxLuagAQAJ
    (fetchpatch {
      hash = "sha256-VNiLv1y3cjSDCNen9KxqbdrldI6EhshTSnsq8g9x8HA=";
      name = "0001-libwebp-Fix-endianness-with-CMake.patch";
      url = "https://github.com/webmproject/libwebp/commit/0e5f4ee3deaba5c4381877764005d981f652791f.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs =
    [ ]
    ++ lib.optionals openglSupport [
      libglut
      libGL
      libGLU
    ]
    ++ lib.optionals pngSupport [ libpng ]
    ++ lib.optionals jpegSupport [ libjpeg ]
    ++ lib.optionals tiffSupport [ libtiff ]
    ++ lib.optionals gifSupport [ giflib ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "WEBP_USE_THREAD" threadingSupport)
    (lib.cmakeBool "WEBP_BUILD_VWEBP" openglSupport)
    (lib.cmakeBool "WEBP_BUILD_IMG2WEBP" (pngSupport || jpegSupport || tiffSupport))
    (lib.cmakeBool "WEBP_BUILD_GIF2WEBP" gifSupport)
    (lib.cmakeBool "WEBP_BUILD_ANIM_UTILS" false) # Not installed
    (lib.cmakeBool "WEBP_BUILD_EXTRAS" false) # Not installed
    (lib.cmakeBool "WEBP_ENABLE_SWAP_16BIT_CSP" swap16bitcspSupport)
    (lib.cmakeBool "WEBP_BUILD_LIBWEBPMUX" libwebpmuxSupport)
  ];

  passthru.tests = {
    inherit
      gd
      graphicsmagick
      imagemagick
      imlib2
      libjxl
      opencv
      vips
      ;

    inherit (python3.pkgs) pillow imread;
    haskell-webp = haskellPackages.webp;
    pkg-config = testers.hasPkgConfigModules { package = libwebp; };
  };

  meta = {
    description = "Tools and library for the WebP image format";
    homepage = "https://developers.google.com/speed/webp/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      ajs124
      savtrip
    ];

    platforms = lib.platforms.all;

    pkgConfigModules = [
      # configure_pkg_config() calls for these are unconditional
      "libwebp"
      "libwebpdecoder"
      "libwebpdemux"
      "libsharpyuv"
    ]
    ++ lib.optionals libwebpmuxSupport [
      "libwebpmux"
    ];
  };
})

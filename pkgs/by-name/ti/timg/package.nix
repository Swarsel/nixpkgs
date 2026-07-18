{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  ffmpeg,
  graphicsmagick,
  libdeflate,
  libexif,
  libjpeg,
  librsvg,
  libsixel,
  openslide,
  pkg-config,
  poppler,
  qoi,
  stb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "timg";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "hzeller";
    repo = "timg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FdaO+UAKjmLKgVZ3AYGQ9VJQj9s48Ihr8TlZ4at5I3c=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    graphicsmagick
    libdeflate
    libexif
    libjpeg
    libsixel
    openslide
    poppler
    librsvg
    cairo
    qoi.dev
    stb
  ];

  cmakeFlags = [
    "-DTIMG_VERSION_FROM_GIT=Off"
    "-DWITH_VIDEO_DECODING=On"
    "-DWITH_VIDEO_DEVICE=On"
    "-DWITH_OPENSLIDE_SUPPORT=On"
    "-DWITH_LIBSIXEL=On"
  ];

  meta = {
    description = "Terminal image and video viewer";
    homepage = "https://timg.sh/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ hzeller ];
    platforms = lib.platforms.unix;
    mainProgram = "timg";
  };
})

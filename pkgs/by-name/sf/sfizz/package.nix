{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  catch2,
  cmake,
  flac,
  freetype,
  glib,
  libjack2,
  libogg,
  libopus,
  libsndfile,
  libvorbis,
  libx11,
  libxau,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxdmcp,
  libxkbcommon,
  pango,
  pkg-config,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sfizz";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "sfztools";
    repo = "sfizz";
    tag = finalAttrs.version;
    hash = "sha256-347olgxCyCRmKX0jxgBkYkoBuy9TMbsQgWOIoMppUAo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libjack2
    libsndfile
    flac
    libogg
    libvorbis
    libopus
    libx11
    libxcb
    libxau
    libxdmcp
    libxcb-util
    libxcb-cursor
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxkbcommon
    cairo
    glib
    zenity
    freetype
    pango
  ];

  cmakeFlags = [
    (lib.cmakeBool "SFIZZ_TESTS" true)
  ];

  doCheck = true;

  meta = {
    description = "SFZ jack client and LV2 plugin";
    homepage = "https://github.com/sfztools/sfizz";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
  };
})

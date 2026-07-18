{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  expat,
  freetype,
  glib,
  imagemagick,
  libjpeg,
  libpng,
  libxml2,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwmf";
  version = "0.2.15";

  src = fetchFromGitHub {
    owner = "caolanm";
    repo = "libwmf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bpxr04dQ6EjX1FBVF4KcbJQvUjsPK6L03xLIXG6F2FI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    zlib
    imagemagick
    libpng
    glib
    freetype
    libjpeg
    libxml2
    expat
  ];

  enableParallelBuilding = true;

  meta = {
    description = "WMF library from wvWare";
    homepage = "https://wvware.sourceforge.net/libwmf.html";
    changelog = "https://github.com/caolanm/libwmf/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/caolanm/libwmf/releases";
  };
})

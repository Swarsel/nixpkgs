{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cairo,
  doxygen,
  gdk-pixbuf,
  glib,
  libdicom,
  libjpeg,
  libpng,
  libtiff,
  libxml2,
  meson,
  ninja,
  openjpeg,
  pkg-config,
  sqlite,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openslide";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "openslide";
    repo = "openslide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9LvQ7FG/0E0WpFyIUyrL4Fvn60iYWejjbgdKHMVOFdI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    doxygen
  ];

  buildInputs = [
    cairo
    glib
    gdk-pixbuf
    libdicom
    libjpeg
    libpng
    libtiff
    libxml2
    openjpeg
    sqlite
    zlib
    zstd
  ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  meta = {
    description = "C library that provides a simple interface to read whole-slide images";
    homepage = "https://openslide.org";
    changelog = "https://github.com/openslide/openslide/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ lromor ];
    platforms = lib.platforms.unix;
    mainProgram = "slidetool";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  boost,
  cairo,
  cmake,
  enblend-enfuse,
  exiv2,
  fftw,
  flann,
  gettext,
  glew,
  gnumake,
  lcms2,
  lensfun,
  libGL,
  libGLU,
  libjpeg,
  libpng,
  libtiff,
  libx11,
  libxi,
  libxmu,
  makeWrapper,
  openexr,
  panotools,
  perlPackages,
  pkg-config,
  sqlite,
  vigra,
  wrapGAppsHook3,
  wxwidgets_3_2,
  zlib,
  wxGTK' ? wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hugin";
  version = "2025.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/hugin/hugin-${finalAttrs.version}.tar.bz2";
    hash = "sha256-fPjrM6aohIzH+Bb69LyIOJIoiD1VExNtzLXLJDkSq3k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    wrapGAppsHook3
    wxGTK'
  ];

  buildInputs = [
    boost
    cairo
    exiv2
    fftw
    flann
    gettext
    glew
    lcms2
    lensfun
    libjpeg
    libpng
    libtiff
    libx11
    libxi
    libxmu
    libGLU
    libGL
    openexr
    panotools
    sqlite
    vigra
    wxGTK'
    zlib
  ];

  # disable installation of the python scripting interface
  cmakeFlags = [ "-DBUILD_HSI:BOOl=OFF" ];

  postInstall = ''
    for p in $out/bin/*; do
      wrapProgram "$p" \
        --suffix PATH : ${enblend-enfuse}/bin \
        --suffix PATH : ${gnumake}/bin \
        --suffix PATH : ${perlPackages.ImageExifTool}/bin
    done
  '';

  # hugin libs are added to NEEDED but not to RUNPATH
  postFixup = ''
    for p in $out/bin/..*; do
      patchelf "$p" --add-rpath $out/lib/hugin
    done
  '';

  meta = {
    description = "Toolkit for stitching photographs and assembling panoramas, together with an easy to use graphical front end";
    homepage = "https://hugin.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})

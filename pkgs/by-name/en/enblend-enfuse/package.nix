{
  lib,
  stdenv,
  autoreconfHook,
  boost,
  fetchhg,
  glew,
  gsl,
  help2man,
  lcms2,
  libGL,
  libGLU,
  libglut,
  libjpeg,
  libpng,
  libtiff,
  perl,
  pkg-config,
  texliveSmall,
  vigra,
}:

stdenv.mkDerivation {
  pname = "enblend-enfuse";
  version = "unstable-2022-03-06";

  src = fetchhg {
    url = "http://hg.code.sf.net/p/enblend/code";
    rev = "0f423c72e51872698fe2985ca3bd453961ffe4e0";
    sha256 = "sha256-0gCUSdg3HR3YeIbOByEBCZh2zGlYur6DeCOzUM53fdc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    help2man
    perl
    pkg-config
    texliveSmall
  ];

  buildInputs = [
    boost
    libglut
    glew
    gsl
    lcms2
    libjpeg
    libpng
    libtiff
    libGLU
    libGL
    vigra
  ];

  preConfigure = ''
    patchShebangs src/embrace
  '';

  meta = {
    description = "Blends away the seams in a panoramic image mosaic using a multiresolution spline";
    homepage = "https://enblend.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; linux;
  };
}

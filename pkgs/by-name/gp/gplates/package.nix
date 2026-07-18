{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cgal,
  cmake,
  doxygen,
  gdal,
  glew,
  gmp,
  graphviz,
  libGL,
  libGLU,
  libsForQt5,
  libsm,
  mpfr,
  proj,
  python3,
}:

let
  python = python3.withPackages (
    ps: with ps; [
      numpy
    ]
  );
  boost' = boost.override {
    inherit python;
    enablePython = true;
  };
  cgal' = cgal.override {
    boost = boost';
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gplates";
  version = "2.5.0-dev3";

  src = fetchFromGitHub {
    owner = "GPlates";
    repo = "GPlates";
    rev = "e3ec5a4ee58147d21d8b42050c4c7e78f861f21c";
    hash = "sha256-/y+fozK6DvoVuS1I1ZdWtRwy+M/XRFyLDWHcUFu2++M=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    boost'
    cgal'
    gdal
    glew
    gmp
    libGL
    libGLU
    libsm
    mpfr
    proj
    python
    libsForQt5.qtxmlpatterns
    libsForQt5.qwt
  ];

  meta = {
    description = "Desktop software for the interactive visualisation of plate-tectonics";
    homepage = "https://www.gplates.org";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    mainProgram = "gplates";
    broken = stdenv.hostPlatform.isDarwin; # FIX: this check: https://github.com/GPlates/GPlates/blob/gplates/cmake/modules/Config_h.cmake#L72
  };
})

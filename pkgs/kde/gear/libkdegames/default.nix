{
  _7zz,
  libsndfile,
  mkKdeDerivation,
  openal,
  qtdeclarative,
  qtsvg,
  svgcleaner,
}:
mkKdeDerivation {
  pname = "libkdegames";

  extraBuildInputs = [
    openal
    libsndfile
    qtdeclarative
    qtsvg
  ];

  extraNativeBuildInputs = [
    _7zz
    svgcleaner
  ];
}

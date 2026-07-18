{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  libGL,
  libGLU,
  libglut,
  libxi,
  libxmu,
  python3,
  swig,
  unzip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "partio";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "wdas";
    repo = "partio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uzMp3jj0HUB6vOjc/uvvT4Bmi6xp0qz4OYPG+bmlgaM=";
  };

  outputs = [
    "dev"
    "out"
    "lib"
  ];

  # TODO:
  # Sexpr support
  strictDeps = true;

  nativeBuildInputs = [
    unzip
    cmake
    doxygen
    python3
  ];

  buildInputs = [
    zlib
    swig
    libxi
    libxmu
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libglut
    libGLU
    libGL
  ];

  meta = {
    description = "C++ (with python bindings) library for easily reading/writing/manipulating common animation particle formats such as PDB, BGEO, PTC";
    homepage = "https://github.com/wdas/partio";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.guibou ];
    platforms = lib.platforms.unix;
  };
})

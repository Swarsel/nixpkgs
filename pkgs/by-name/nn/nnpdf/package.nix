{
  lib,
  stdenv,
  fetchFromGitHub,
  apfel,
  cmake,
  gsl,
  lhapdf,
  libarchive,
  pkg-config,
  python3,
  sqlite,
  swig,
  yaml-cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nnpdf";
  version = "4.0.9";

  src = fetchFromGitHub {
    owner = "NNPDF";
    repo = "nnpdf";
    rev = finalAttrs.version;
    hash = "sha256-PyhkHlOlzKfDxUX91NkeZWjdEzFR4PW0Yh5Yz6ZA27g=";
  };

  postPatch = ''
    for file in CMakeLists.txt buildmaster/CMakeLists.txt; do
      substituteInPlace $file \
        --replace "-march=nocona -mtune=haswell" ""
    done

    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 3.0.2)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    apfel
    gsl
    lhapdf
    libarchive
    yaml-cpp
    python3
    python3.pkgs.numpy
    sqlite
    swig
  ];

  cmakeFlags = [
    "-DCOMPILE_filter=ON"
    "-DCOMPILE_evolvefit=ON"
  ];

  meta = {
    description = "Open-source machine learning framework for global analyses of parton distributions";
    homepage = "https://docs.nnpdf.science/";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.veprbl ];
    platforms = lib.platforms.unix;
    mainProgram = "evolven3fit";
  };
})

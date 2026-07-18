{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  eigen,
  fplll,
  gmp,
  llvmPackages,
  mpfr,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "flatter";
  version = "0-unstable-2025-08-25";

  src = fetchFromGitHub {
    owner = "keeganryan";
    repo = "flatter";
    rev = "d2b8026f29b4a69e987b15d4b240f8a5053275d3";
    hash = "sha256-NAefYPJ+syTmpDiOzkgKB1IZmgQ2DNmvLrtoBee/IX4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    blas
    gmp
    mpfr
    fplll
    eigen
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.openmp
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Fast lattice reduction of integer lattice bases";
    homepage = "https://github.com/keeganryan/flatter";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ josephsurin ];
    platforms = lib.platforms.all;
    mainProgram = "flatter";
  };
}

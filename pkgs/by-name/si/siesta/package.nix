{
  lib,
  stdenv,
  fetchFromGitLab,
  blas,
  cmake,
  elpa,
  gfortran,
  lapack,
  mpi,
  ninja,
  nix-update-script,
  pkg-config,
  readline,
  scalapack,
  useMpi ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "siesta";
  version = "5.4.1";

  src = fetchFromGitLab {
    owner = "siesta-project";
    repo = "siesta";
    tag = finalAttrs.version;
    hash = "sha256-pud8RlJAT+0TwyPRsbf5D/8FfLjZvPYPf84Xb7UH6os=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    ninja
    gfortran
    cmake
    pkg-config
  ];

  buildInputs = [
    blas
    lapack
    readline
    elpa
  ]
  ++ lib.optionals useMpi [
    mpi
    scalapack
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  env.NIX_LDFLAGS = "-lm";

  preBuild =
    if useMpi then
      ''
        makeFlagsArray+=(
            CC="mpicc" FC="mpifort"
            FPPFLAGS="-DMPI" MPI_INTERFACE="libmpi_f90.a" MPI_INCLUDE="."
            COMP_LIBS="" LIBS="-lblas -llapack -lscalapack"
        );
      ''
    else
      ''
        makeFlagsArray+=(
          COMP_LIBS="" LIBS="-lblas -llapack"
        );
      '';

  enableParallelBuilding = false; # Started making trouble with gcc-11

  passthru = {
    inherit mpi;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "First-principles materials simulation code using DFT";

    longDescription = ''
      SIESTA is both a method and its computer program
      implementation, to perform efficient electronic structure
      calculations and ab initio molecular dynamics simulations of
      molecules and solids. SIESTA's efficiency stems from the use
      of strictly localized basis sets and from the implementation
      of linear-scaling algorithms which can be applied to suitable
      systems. A very important feature of the code is that its
      accuracy and cost can be tuned in a wide range, from quick
      exploratory calculations to highly accurate simulations
      matching the quality of other approaches, such as plane-wave
      and all-electron methods.
    '';

    homepage = "https://siesta-project.org/siesta/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.costrouc ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "siesta";
  };
})

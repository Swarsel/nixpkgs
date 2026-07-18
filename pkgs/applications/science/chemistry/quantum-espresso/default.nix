{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchFromGitLab,
  blas,
  cmake,
  fftw,
  gfortran,
  git,
  hdf5,
  lapack,
  libmbd,
  libxc,
  mpi,
  pkg-config,
  scalapack,
  wannier90,
  enableMpi ? true,
}:

assert !blas.isILP64;
assert !lapack.isILP64;

let
  # "rev"s must exactly match the git submodule commits in the QE repo
  gitSubmodules = {
    devxlib = fetchFromGitLab {
      group = "max-centre";
      hash = "sha256-p3fRplVG4YSN6ILNlOwf+aSEhpTJPXqiS1+wnzWVA2U=";
      owner = "components";
      repo = "devicexlib";
      rev = "a6b89ef77b1ceda48e967921f1f5488d2df9226d";
    };

    pw2qmcpack = fetchFromGitHub {
      hash = "sha256-K1Z90xexsUvk4SdEb8FGryRal0GAFoLz3j1h/RT2nYw=";
      owner = "QMCPACK";
      repo = "pw2qmcpack";
      rev = "f72ab25fa4ea755c1b4b230ae8074b47d5509c70";
    };
  };

in
stdenv.mkDerivation rec {
  pname = "quantum-espresso";
  version = "7.5";

  src = fetchFromGitLab {
    owner = "QEF";
    repo = "q-e";
    rev = "qe-${version}";
    hash = "sha256-8/7++v53VDfn2P/QcrFRjUSygik3gintVMQwLU4nE24=";
  };

  patches = [
    # this patch reverts commit 5fb5a679, which enforced static library builds.
    ./findLibxc.patch
  ];

  nativeBuildInputs = [
    cmake
    gfortran
    git
    pkg-config
  ];

  buildInputs = [
    fftw
    blas
    lapack
    wannier90
    libmbd
    libxc
    hdf5
  ]
  ++ lib.optional enableMpi scalapack;

  propagatedBuildInputs = lib.optional enableMpi mpi;

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DWANNIER90_ROOT=${wannier90}"
    "-DMBD_ROOT=${libmbd}"
    "-DQE_ENABLE_OPENMP=ON"
    "-DQE_ENABLE_LIBXC=ON"
    "-DQE_ENABLE_HDF5=ON"
    "-DQE_ENABLE_PLUGINS=pw2qmcpack"
  ]
  ++ lib.optionals enableMpi [
    "-DQE_ENABLE_MPI=ON"
    "-DQE_ENABLE_MPI_MODULE=ON"
    "-DQE_ENABLE_SCALAPACK=ON"
  ];

  # add git submodules manually and fix pkg-config file
  prePatch = ''
    chmod -R +rwx external/

    substituteInPlace external/devxlib.cmake \
      --replace "qe_git_submodule_update(external/devxlib)" ""
    substituteInPlace external/CMakeLists.txt \
      --replace "qe_git_submodule_update(external/pw2qmcpack)" "" \
      --replace "qe_git_submodule_update(external/d3q)" "" \
      --replace "qe_git_submodule_update(external/qe-gipaw)" ""

    ${toString (
      builtins.attrValues (
        builtins.mapAttrs (name: val: ''
          cp -r ${val}/* external/${name}/.
          chmod -R +rwx external/${name}
        '') gitSubmodules
      )
    )}

    substituteInPlace cmake/quantum_espresso.pc.in \
      --replace 'libdir="''${prefix}/@CMAKE_INSTALL_LIBDIR@"' 'libdir="@CMAKE_INSTALL_FULL_LIBDIR@"' \
      --replace 'includedir="''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@/qe"' 'includedir="@CMAKE_INSTALL_FULL_INCLUDEDIR@/qe"' \
      --replace 'moduledir="''${prefix}/@QE_INSTALL_Fortran_MODULES@/qe"' 'moduledir="@CMAKE_INSTALL_FULL_INCLUDEDIR@/qe"'
  '';

  propagatedUserEnvPkgs = lib.optional enableMpi mpi;
  passthru = { inherit mpi; };

  meta = {
    description = "Electronic-structure calculations and materials modeling at the nanoscale";

    longDescription = ''
      Quantum ESPRESSO is an integrated suite of Open-Source computer codes for
      electronic-structure calculations and materials modeling at the
      nanoscale. It is based on density-functional theory, plane waves, and
      pseudopotentials.
    '';

    homepage = "https://www.quantum-espresso.org/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.costrouc ];

    platforms = [
      "x86_64-linux"
    ];
  };
}

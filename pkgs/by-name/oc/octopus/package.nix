{
  lib,
  stdenv,
  fetchFromGitLab,
  arpack,
  blas,
  cmake,
  fftw,
  gfortran,
  gsl,
  lapack,
  libvdwxc,
  libxc,
  libyaml,
  metis,
  mpi,
  netcdf,
  ninja,
  perl,
  pkg-config,
  procps,
  python3,
  scalapack,
  spglib,
  which,
  enableMpi ? true,
}:

assert (!blas.isILP64) && (!lapack.isILP64);
assert (blas.isILP64 == arpack.isILP64);

stdenv.mkDerivation (finalAttrs: {
  pname = "octopus";
  version = "16.3";

  src = fetchFromGitLab {
    owner = "octopus-code";
    repo = "octopus";
    tag = finalAttrs.version;
    hash = "sha256-3DYfgoKznIWY8/HZByzz0MX03QzbivU9B3gDyNMnTQ4=";
  };

  outputs = [
    "out"
    "dev"
    "testsuite"
  ];

  postPatch = ''
    patchShebangs ./
  '';

  nativeBuildInputs = [
    which
    perl
    procps
    cmake
    gfortran
    pkg-config
    ninja
  ];

  buildInputs = [
    libyaml
    libxc
    blas
    lapack
    gsl
    fftw
    netcdf
    arpack
    libvdwxc
    spglib
    metis
    (python3.withPackages (ps: [ ps.pyyaml ]))
  ]
  ++ lib.optional enableMpi scalapack;

  propagatedBuildInputs = lib.optional enableMpi mpi;

  cmakeFlags = [
    (lib.cmakeBool "OCTOPUS_MPI" enableMpi)
    (lib.cmakeBool "OCTOPUS_ScaLAPACK" enableMpi)
    (lib.cmakeBool "OCTOPUS_OpenMP" true)
    (lib.cmakeBool "OCTOPUS_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  postConfigure = ''
    patchShebangs testsuite/oct-run_testsuite.sh
  '';

  doCheck = false; # requires installed data
  nativeCheckInputs = lib.optional enableMpi mpi;

  postInstall = ''
    mkdir -p $testsuite
    moveToOutput share/octopus/testsuite $testsuite
  '';

  enableParallelBuilding = true;
  propagatedUserEnvPkgs = lib.optional enableMpi mpi;
  passthru = lib.attrsets.optionalAttrs enableMpi { inherit mpi; };

  meta = {
    description = "Real-space time dependent density-functional theory code";
    homepage = "https://octopus-code.org";

    license = with lib.licenses; [
      gpl2Only
      asl20
      lgpl3Plus
      bsd3
    ];

    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
})

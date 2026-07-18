{
  lib,
  stdenv,
  fetchFromGitLab,
  bison,
  bzip2,
  cmake,
  flex,
  gfortran,
  mpi,
  mpiCheckPhaseHook,
  nix-update-script,
  testers,
  xz,
  zlib,
  pkgsMusl ? { }, # default to empty set to avoid CI fails with allowVariants = false
  withPtScotch ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scotch";
  version = "7.0.12";

  src = fetchFromGitLab {
    owner = "scotch";
    repo = "scotch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DE0VCGCSOOeSRIz/LQPCBNSBTNmXQtYAUKm3EeqnDBs=";
    domain = "gitlab.inria.fr";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    cmake
    gfortran
    bison
    flex
  ];

  buildInputs = [
    bzip2
    xz
    zlib
  ];

  propagatedBuildInputs = lib.optionals withPtScotch [
    mpi
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_PTSCOTCH" withPtScotch)
    # Prefix Scotch version of MeTiS routines
    (lib.cmakeBool "SCOTCH_METIS_PREFIX" true)
    (lib.cmakeBool "ENABLE_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  nativeCheckInputs = lib.optionals withPtScotch [
    mpiCheckPhaseHook
  ];

  # SCOTCH provide compatibility with Metis/Parmetis interface.
  # We install the metis compatible headers to subdirectory to
  # avoid conflict with metis/parmetis.
  postFixup = ''
    mkdir -p $dev/include/scotch
    mv $dev/include/{*metis,metisf}.h $dev/include/scotch
  '';

  __darwinAllowLocalNetworking = withPtScotch;

  passthru = {
    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        moduleNames = [ "SCOTCH" ];
        package = finalAttrs.finalPackage;
      };

      musl = pkgsMusl.scotch or null;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering";

    longDescription = ''
      Scotch is a software package for graph and mesh/hypergraph partitioning, graph clustering,
      and sparse matrix ordering.
    '';

    homepage = "http://www.labri.fr/perso/pelegrin/scotch";
    license = lib.licenses.cecill-c;

    maintainers = with lib.maintainers; [
      bzizou
      qbisi
    ];
  };
})

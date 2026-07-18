{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  bzip2,
  coin-utils,
  cplex,
  gfortran,
  gurobi,
  pkg-config,
  zlib,
  withCplex ? false,
  withGurobi ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osi";
  version = "0.108.11";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "Osi";
    rev = "releases/${finalAttrs.version}";
    hash = "sha256-3aTO7JGEOP/RCOZ1X9b68rrtv6T78euf1TYGTjyXSRE=";
  };

  nativeBuildInputs = [
    gfortran
    pkg-config
  ];

  buildInputs = [
    blas
    zlib
    bzip2
    coin-utils
  ]
  ++ lib.optional withGurobi gurobi
  ++ lib.optional withCplex cplex;

  configureFlags =
    lib.optionals withGurobi [
      "--with-gurobi-incdir=${gurobi}/include"
      "--with-gurobi-lib=-lgurobi${gurobi.libSuffix}"
    ]
    ++ lib.optionals withCplex [
      "--with-cplex-incdir=${cplex}/cplex/include/ilcplex"
      "--with-cplex-lib=-lcplex${cplex.libSuffix}"
    ];

  env = {
    # Compile errors
    NIX_CFLAGS_COMPILE = "-Wno-cast-qual";
  }
  // lib.optionalAttrs withCplex {
    NIX_LDFLAGS = "-L${cplex}/cplex/bin/${cplex.libArch}";
  };

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];
  passthru = { inherit withGurobi withCplex; };

  meta = {
    description = "Abstract base class to a generic linear programming (LP) solver";
    homepage = "https://github.com/coin-or/Osi";
    license = lib.licenses.epl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})

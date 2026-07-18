{
  lib,
  stdenv,
  cmake,
  fetchzip,
  gmp,
  mpi,
  scipopt-scip,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "scipopt-ug";
  version = "1.0.1";

  # Take the SCIPOptSuite source since no other source exists publicly.
  src = fetchzip {
    url = "https://github.com/scipopt/scip/releases/download/v${scipVersion}/scipoptsuite-${scipVersion}.tgz";
    hash = "sha256-U5tbgGCzUkDL/22RwQLQmvCjSAhxehJe0P5rwNupW6Q=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    scipopt-scip
    mpi
    zlib
    gmp
  ];

  # To correlate scipVersion and version, check: https://scipopt.org/#news
  scipVersion = "10.0.1";
  sourceRoot = "${src.name}/ug";

  meta = {
    description = "Ubiquity Generator framework to parallelize branch-and-bound based solvers";
    homepage = "https://ug.zib.de";
    changelog = "https://scipopt.org/doc-${scipVersion}/html/RN${lib.versions.major scipVersion}.php";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ pmeinhold ];
  };
}

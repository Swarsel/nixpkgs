{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  criterion,
  gfortran,
  gmp,
  ipopt,
  mpfr,
  onetbb,
  readline,
  scipopt-papilo,
  scipopt-soplex,
  scipopt-zimpl,
  zlib,
  enableZimpl ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scipopt-scip";
  version = "10.0.3";

  src = fetchFromGitHub {
    owner = "scipopt";
    repo = "scip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dR2H18xLbLko3AQMiEwAL5mzLYcUD9U9g3AjWDT5Kz8=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    scipopt-soplex
    scipopt-papilo
    ipopt
    gmp
    readline
    zlib
    onetbb
    boost
    gfortran
    criterion
  ]
  ++ lib.optional enableZimpl scipopt-zimpl;

  propagatedBuildInputs = [ mpfr ];
  cmakeFlags = lib.optional (!enableZimpl) "-DZIMPL=OFF";
  doCheck = true;

  meta = {
    description = "Solving Constraint Integer Programs";
    homepage = "https://github.com/scipopt/scip";
    changelog = "https://scipopt.org/doc-${finalAttrs.version}/html/RN${lib.versions.major finalAttrs.version}.php";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pmeinhold ];
    mainProgram = "scip";
  };
})

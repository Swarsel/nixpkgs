{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  boost,
  cmake,
  gfortran,
  gmp,
  onetbb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scipopt-papilo";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "scipopt";
    repo = "papilo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YDaahgsE7NqTNE1WvkSp5DwyvfJrP19IcytTkM8VKZo=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    blas
    gmp
    gfortran
    boost
    onetbb
  ];

  cmakeFlags = [
    # Disable automatic download of TBB.
    (lib.cmakeBool "TBB_DOWNLOAD" false)

    # Explicitly disable SoPlex as a built-in back-end solver to avoid this error:
    #   > include/boost/multiprecision/mpfr.hpp:22: fatal error: mpfr.h: No such file or directory
    #   > compilation terminated.
    (lib.cmakeBool "SOPLEX" false)
  ];

  doCheck = true;

  meta = {
    description = "Parallel Presolve for Integer and Linear Optimization";
    homepage = "https://github.com/scipopt/papilo";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ pmeinhold ];
    mainProgram = "papilo";
  };
})

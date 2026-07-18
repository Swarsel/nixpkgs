{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  gfortran,
  lapack,
  suitesparse,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cholmod-extra";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jluttine";
    repo = "cholmod-extra";
    tag = finalAttrs.version;
    sha256 = "0hz1lfp0zaarvl0dv0zgp337hyd8np41kmdpz5rr3fc6yzw7vmkg";
  };

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    suitesparse
    blas
    lapack
  ];

  makeFlags = [
    "BLAS=-lcblas"
  ];

  doCheck = true;

  installFlags = [
    "INSTALL_LIB=$(out)/lib"
    "INSTALL_INCLUDE=$(out)/include"
  ];

  meta = {
    description = "Set of additional routines for SuiteSparse CHOLMOD Module";
    homepage = "https://github.com/jluttine/cholmod-extra";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ jluttine ];
    platforms = with lib.platforms; unix;
  };

})

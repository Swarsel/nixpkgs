{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adolc";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "ADOL-C";
    tag = "releases/${finalAttrs.version}";
    hash = "sha256-oU229SuOl/gHoRT8kiWfd5XFiByjeypgdVWFLMYFHfA=";
  };

  buildInputs = lib.optional stdenv.cc.isClang llvmPackages.openmp;

  configureFlags = [
    "--with-openmp-flag=-fopenmp"
    "--enable-sparse"
  ];

  meta = {
    description = "Automatic Differentiation of C/C++";
    homepage = "https://github.com/coin-or/ADOL-C";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bzizou ];
  };
})

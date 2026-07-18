{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  blas,
  gmp,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "iml";
  version = "1.0.5";

  src = fetchurl {
    url = "https://www.cs.uwaterloo.ca/~astorjoh/iml-${finalAttrs.version}.tar.bz2";
    sha256 = "0akwhhz9b40bz6lrfxpamp7r7wkk48p455qbn04mfnl9a1l6db8x";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    gmp
    blas
  ];

  configureFlags = [
    "--with-gmp-include=${gmp.dev}/include"
    "--with-gmp-lib=${gmp}/lib"
    "--with-cblas=-lblas"
  ];

  meta = {
    description = "Algorithms for computing exact solutions to dense systems of linear equations over the integers";
    homepage = "https://cs.uwaterloo.ca/~astorjoh/iml.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
  };
})

{
  lib,
  stdenv,
  fetchurl,
  blas,
  gfortran,
  lapack,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "JAGS";
  version = "4.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/mcmc-jags/JAGS-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-hx9VavQDp8LOag8C8Vz4WlcnY+CT0mZY66xVxKtHL8g=";
  };

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    blas
    lapack
  ];

  configureFlags = [
    "--with-blas=-lblas"
    "--with-lapack=-llapack"
  ];

  meta = {
    description = "Just Another Gibbs Sampler";
    homepage = "http://mcmc-jags.sourceforge.net";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.andres ];
    platforms = lib.platforms.unix;
    mainProgram = "jags";
  };
})

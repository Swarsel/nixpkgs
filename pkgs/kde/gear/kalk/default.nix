{
  bison,
  flex,
  gmp,
  libqalculate,
  mkKdeDerivation,
  mpfr,
  pkg-config,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kalk";

  extraBuildInputs = [
    qtdeclarative
    gmp
    mpfr
    libqalculate
  ];

  extraNativeBuildInputs = [
    pkg-config
    bison
    flex
  ];

  meta.mainProgram = "kalk";
}

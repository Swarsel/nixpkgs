{
  gmp,
  libmpc,
  mkKdeDerivation,
  mpfr,
  qt5compat,
}:
mkKdeDerivation {
  pname = "kcalc";

  extraBuildInputs = [
    qt5compat
    gmp
    libmpc
    mpfr
  ];

  meta.mainProgram = "kcalc";
}

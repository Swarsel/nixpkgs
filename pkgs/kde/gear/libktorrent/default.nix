{
  boost,
  doxygen,
  gmp,
  libgcrypt,
  mkKdeDerivation,
  qt5compat,
}:
mkKdeDerivation {
  pname = "libktorrent";
  extraBuildInputs = [ qt5compat ];
  extraNativeBuildInputs = [ doxygen ];

  extraPropagatedBuildInputs = [
    boost
    gmp
    libgcrypt
  ];
}

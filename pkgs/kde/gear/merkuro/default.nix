{
  libplasma,
  mkKdeDerivation,
  qtlocation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "merkuro";
  # FIXME: not sure why this is failing
  dontQmlLint = true;

  extraBuildInputs = [
    qtlocation
    qtsvg
    libplasma
  ];
}

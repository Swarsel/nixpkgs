{
  boost,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "rocs";
  extraBuildInputs = [ boost ];
}

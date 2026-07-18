{
  boost,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "zanshin";
  extraBuildInputs = [ boost ];
}

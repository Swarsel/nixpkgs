{
  libxxf86vm,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kgamma";
  extraBuildInputs = [ libxxf86vm ];
}

{
  libcanberra,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "knotifyconfig";
  extraBuildInputs = [ libcanberra ];
}
